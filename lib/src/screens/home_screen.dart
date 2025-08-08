import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:provider/provider.dart';

import 'add_transaction_screen.dart';
import '../providers/transaction_entries_provider.dart';
import '../providers/amplify_provider.dart';
import '../widgets/monthly_overview_card.dart';
import '../widgets/platform_loading_indicator.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/platform_app_bar.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../widgets/typography.dart';

class HomeScreen extends StatefulWidget {
  final void Function(String type)? onShowTransactions;
  const HomeScreen({super.key, this.onShowTransactions});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _tooltipTimer;
  bool _showTooltip = false;

  @override
  void dispose() {
    _tooltipTimer?.cancel();
    super.dispose();
  }

  void _startTooltipTimer() {
    _tooltipTimer?.cancel();
    _tooltipTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showTooltip = true;
        });
      }
    });
  }

  void _resetTooltipTimer() {
    if (_showTooltip) {
      setState(() {
        _showTooltip = false;
      });
    }
    _startTooltipTimer();
  }

  void _refreshTransactions() {
    Provider.of<TransactionEntriesProvider>(context, listen: false).loadEntries();
  }

  Map<String, double> _calculateMonthlyTotals(List entries) {
    final currentMonth = DateTime.now();
    final Map<String, double> monthlyTotals = {
      'expense': 0.0,
      'income': 0.0,
    };
    for (final entry in entries) {
      final entryDate = entry.transactedAt;
      if (entryDate.year == currentMonth.year && entryDate.month == currentMonth.month) {
        final type = entry.type.toLowerCase();
        if (monthlyTotals.containsKey(type)) {
          monthlyTotals[type] = monthlyTotals[type]! + entry.amount;
        }
      }
    }
    return monthlyTotals;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
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
          final entries = provider.entries;
          final monthlyTotals = _calculateMonthlyTotals(entries);
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
              // Financial Overview Section (Title)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.horizontalPadding,
                    vertical: 0,
                  ),
                  child: TitleEmphasizedLarge(text: AppStrings.financialOverviewTitle),
                ),
              ),
              // Monthly Overview Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.horizontalPadding,
                    vertical: 0,
                  ),
                  child: MonthlyOverviewCard(
                    entries: entries,
                    onTap: (type) {
                      if (widget.onShowTransactions != null) {
                        widget.onShowTransactions!(type);
                      }
                    },
                  ),
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
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) => const AddTransactionScreen(),
          ).then((_) {
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
