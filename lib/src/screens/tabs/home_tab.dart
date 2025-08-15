import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:ahorro_ui/src/providers/transaction_entries_provider.dart';
import 'package:ahorro_ui/src/providers/amplify_provider.dart';

import 'package:ahorro_ui/src/widgets/platform_loading_indicator.dart';
import 'package:ahorro_ui/src/widgets/error_state_widget.dart';
import 'package:ahorro_ui/src/widgets/month_selector.dart';
import 'package:ahorro_ui/src/widgets/transaction_stats_card.dart';
import 'package:ahorro_ui/src/constants/app_constants.dart';
import 'package:ahorro_ui/src/constants/app_strings.dart';
import 'package:ahorro_ui/src/widgets/typography.dart';
import 'package:ahorro_ui/src/services/api_service.dart';
import 'package:ahorro_ui/src/models/transaction_stats.dart';
import 'package:ahorro_ui/src/screens/tabs/transactions_tab.dart';

class HomeTab extends StatefulWidget {
  final void Function(String type)? onShowTransactions;
  const HomeTab({super.key, this.onShowTransactions});

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when returning to this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshDataOnReturn();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _refreshTransactions() {
    Provider.of<TransactionEntriesProvider>(
      context,
      listen: false,
    ).loadEntries();
  }

  void _refreshDataOnReturn() {
    // Only refresh if the screen is currently visible and mounted
    if (mounted && ModalRoute.of(context)?.isCurrent == true) {
      _refreshTransactions();
      _loadTransactionStats();
    }
  }

  Future<void> _loadTransactionStats() async {
    setState(() {
      _isLoadingStats = true;
      _statsError = null;
    });

    try {
      final startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      final endDate = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        0,
        23,
        59,
        59,
      );
      debugPrint('DEBUG: Loading stats for period $startDate - $endDate');

      final stats = await ApiService.getTransactionStats(
        startDate: startDate,
        endDate: endDate,
      );

      debugPrint(
        'DEBUG: Received stats - expense: ${stats.expense?.currencies.length ?? 0} currencies, income: ${stats.income?.currencies.length ?? 0} currencies',
      );

      if (mounted) {
        setState(() {
          _transactionStats = stats;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statsError = e.toString();
          _isLoadingStats = false;
        });
      }
    }
  }

  void _onMonthChanged(DateTime newMonth) {
    debugPrint('DEBUG: Month changed to ${newMonth.year}-${newMonth.month}');
    setState(() {
      _selectedMonth = newMonth;
    });
    _loadTransactionStats();
  }

  void _navigateToTransactionsWithFilters(String currency, String type) async {
    // Create period dates for selected month
    final startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final endDate = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
      23,
      59,
      59,
    );

    debugPrint('[HOME] Navigating to transactions with filters:');
    debugPrint('[HOME] - currency: $currency');
    debugPrint('[HOME] - type: $type');
    debugPrint('[HOME] - startDate: $startDate');
    debugPrint('[HOME] - endDate: $endDate');

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TransactionsTab(
          initialType: type,
          initialCurrency: currency,
          initialStartDate: startDate,
          initialEndDate: endDate,
        ),
      ),
    );

    // Refresh data when returning from transactions screen
    if (mounted) {
      _refreshTransactions();
      _loadTransactionStats();
    }
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
    final currentDate = DateTime.now();
    final monthYear = DateFormat(
      AppStrings.monthYearDatePattern,
    ).format(currentDate);

    final amplify = context.watch<AmplifyProvider>();
    final displayUserName = amplify.currentUserName ?? 'User';

    return Consumer<TransactionEntriesProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: PlatformLoadingIndicator());
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
                  8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeadlineEmphasizedLarge(
                      text: AppStrings.helloUser(displayUserName),
                    ),
                    const SizedBox(height: 8),
                    LabelEmphasizedMedium(text: monthYear),
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
                    const TitleEmphasizedLarge(
                      text: AppStrings.financialOverviewTitle,
                    ),
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
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      },
    );
  }
}
