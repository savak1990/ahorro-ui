import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../widgets/add_transaction_bottom_sheet.dart';
import '../providers/transaction_entries_provider.dart';
import '../providers/amplify_provider.dart';

import '../widgets/platform_loading_indicator.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/platform_app_bar.dart';
import '../widgets/month_selector.dart';
import '../widgets/transaction_stats_card.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../widgets/typography.dart';
import '../services/api_service.dart';
import '../models/transaction_stats.dart';
import 'transactions_screen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(String type)? onShowTransactions;
  const HomeScreen({super.key, this.onShowTransactions});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedMonth = DateTime.now();
  TransactionStatsResponse? _transactionStats;
  bool _isLoadingStats = false;
  String? _statsError;

  @override
  void initState() {
    super.initState();
    _loadTransactionStats();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _refreshTransactions() {
    Provider.of<TransactionEntriesProvider>(context, listen: false).loadEntries();
  }

  Future<void> _loadTransactionStats() async {
    setState(() {
      _isLoadingStats = true;
      _statsError = null;
    });

    try {
      final startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      final endDate = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);
      print('DEBUG: Loading stats for period $startDate - $endDate');
      
      final stats = await ApiService.getTransactionStats(
        startDate: startDate,
        endDate: endDate,
      );
      
      print('DEBUG: Received stats - expense: ${stats.expense?.currencies.length ?? 0} currencies, income: ${stats.income?.currencies.length ?? 0} currencies');
      
      setState(() {
        _transactionStats = stats;
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        _statsError = e.toString();
        _isLoadingStats = false;
      });
    }
  }

  void _onMonthChanged(DateTime newMonth) {
    print('DEBUG: Month changed to ${newMonth.year}-${newMonth.month}');
    setState(() {
      _selectedMonth = newMonth;
    });
    _loadTransactionStats();
  }

  void _navigateToTransactionsWithFilters(String currency, String type) {
    // Создаем даты периода для выбранного месяца
    final startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final endDate = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TransactionsScreen(
          initialType: type,
          initialCurrency: currency,
          initialStartDate: startDate,
          initialEndDate: endDate,
        ),
      ),
    );
  }

  Widget _buildStatsContent() {
    if (_isLoadingStats) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: PlatformLoadingIndicator(),
        ),
      );
    }

    if (_statsError != null) {
      return ErrorStateWidget(
        message: 'Error loading statistics: $_statsError',
        onRetry: _loadTransactionStats,
      );
    }

    if (_transactionStats == null) {
      return const SizedBox.shrink();
    }

    return TransactionStatsCard(
      stats: _transactionStats!,
      onTapCurrency: _navigateToTransactionsWithFilters,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentDate = DateTime.now();
    final monthYear = DateFormat(AppStrings.monthYearDatePattern).format(currentDate);

    final amplify = context.watch<AmplifyProvider>();
    final displayUserName = amplify.currentUserName ?? 'User';

    return Scaffold(
      appBar: PlatformAppBar(
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            icon: Icon(
              Icons.person,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/account');
            },
          ),
        ],
      ),
      body: Consumer<TransactionEntriesProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(child: PlatformLoadingIndicator());
          }
          if (provider.error != null) {
            return ErrorStateWidget(
              message: 'Error loading transactions: ${provider.error}',
              onRetry: _refreshTransactions,
            );
          }
          return CustomScrollView(
            slivers: [
              // Header section (Headline + Label)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.horizontalPadding, 
                    8,
                    AppConstants.horizontalPadding, 
                    8
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeadlineEmphasizedLarge(
                        text: AppStrings.helloUser(displayUserName),
                      ),
                      const SizedBox(height: 8),
                      LabelEmphasizedMedium(
                        text: monthYear,
                      ),
                    ],
                  ),
                ),
              ),
              // Financial Overview Section (Title + Month Selector)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.horizontalPadding,
                    vertical: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const TitleEmphasizedLarge(text: AppStrings.financialOverviewTitle),
                      MonthSelector(
                        selectedMonth: _selectedMonth,
                        onMonthChanged: _onMonthChanged,
                      ),
                    ],
                  ),
                ),
              ),
              // Transaction Stats Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.horizontalPadding,
                    vertical: 16,
                  ),
                  child: _buildStatsContent(),
                ),
              ),
              // Bottom padding for FAB
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddTransactionBottomSheet(context).then((_) {
            _refreshTransactions();
          });
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
