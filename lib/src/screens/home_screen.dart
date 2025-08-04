import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../services/api_service.dart';
import '../widgets/list_item_tile.dart';
import 'add_transaction_screen.dart';
import '../providers/categories_provider.dart';
import '../providers/balances_provider.dart';
import '../providers/merchants_provider.dart';
import '../providers/transaction_entries_provider.dart';
import '../widgets/monthly_overview_card.dart';
import '../widgets/home_header.dart';
import '../widgets/section_title.dart';
import '../widgets/platform_loading_indicator.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/platform_app_bar.dart';

class HomeScreen extends StatefulWidget {
  final void Function(String type)? onShowTransactions;
  const HomeScreen({super.key, this.onShowTransactions});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _tooltipTimer;
  bool _showTooltip = false;
  late Future<String> _userNameFuture;

  Future<String> _fetchUserName() async {
    try {
      final attributes = await Amplify.Auth.fetchUserAttributes();
      final nameAttr = attributes.firstWhere(
        (attr) => attr.userAttributeKey.key == 'name',
        orElse: () => const AuthUserAttribute(
          userAttributeKey: CognitoUserAttributeKey.name,
          value: 'User',
        ),
      );
      return nameAttr.value;
    } catch (e) {
      return 'User';
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final categoriesProvider = Provider.of<CategoriesProvider>(context, listen: false);
      categoriesProvider.loadCategories();
      final balancesProvider = Provider.of<BalancesProvider>(context, listen: false);
      balancesProvider.loadBalances().then((_) {
        final balances = balancesProvider.balances;
        final hasActive = balances.any((b) => b.deletedAt == null);
        if (!hasActive) {
          Navigator.of(context).pushReplacementNamed('/default-balance-currency');
        }
      });
      final merchantsProvider = Provider.of<MerchantsProvider>(context, listen: false);
      merchantsProvider.loadMerchants();
      Provider.of<TransactionEntriesProvider>(context, listen: false).loadEntries();
    });
    _userNameFuture = _fetchUserName();
  }

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
          print('Tooltip should be visible now: $_showTooltip');
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
    final monthYear = DateFormat('MMMM, yyyy').format(currentDate);

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
      body: FutureBuilder<String>(
        future: _userNameFuture,
        builder: (context, nameSnapshot) {
          String displayUserName = 'User';
          if (nameSnapshot.connectionState == ConnectionState.done && nameSnapshot.hasData && nameSnapshot.data!.isNotEmpty) {
            displayUserName = nameSnapshot.data!;
          }
          return Consumer<TransactionEntriesProvider>(
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
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section using reusable widget
                    HomeHeader(
                      userName: displayUserName,
                      dateText: monthYear,
                    ),
                    //const SizedBox(height: 32),
                    // Financial Overview Section using reusable widget
                    SectionTitle(title: 'Financial Overview'),
                    //const SizedBox(height: 16),
                    MonthlyOverviewCard(
                      entries: entries,
                      onTap: (type) {
                        if (widget.onShowTransactions != null) {
                          widget.onShowTransactions!(type);
                        }
                      },
                    ),

                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) => const AddTransactionScreen(),
          ).then((_) {
            // Update transactions after adding new one
            _refreshTransactions();
          });
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
