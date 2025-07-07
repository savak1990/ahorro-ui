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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _tooltipTimer;
  bool _showTooltip = false;
  late Future<String> _userNameFuture;
  late Future<Map<String, double>> _transactionsFuture;

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

  Future<Map<String, double>> _fetchTransactions() async {
    try {
      final response = await ApiService.getTransactions();
      final currentMonth = DateTime.now();
      
      debugPrint('Fetched ${response.transactionEntries.length} transactions');
      debugPrint('Current month: ${currentMonth.year}-${currentMonth.month}');
      
      // Group transactions by month and type
      final Map<String, double> monthlyTotals = {
        'expense': 0.0,
        'income': 0.0,
      };

      for (final entry in response.transactionEntries) {
        final entryDate = entry.transactedAt;
        debugPrint('Transaction: type=${entry.type}, amount=${entry.amount}, date=${entryDate.year}-${entryDate.month}');
        
        // Check that transaction is from current month
        if (entryDate.year == currentMonth.year && 
            entryDate.month == currentMonth.month) {
          
          final type = entry.type.toLowerCase();
          debugPrint('Adding to monthly totals: $type += ${entry.amount}');
          if (monthlyTotals.containsKey(type)) {
            monthlyTotals[type] = monthlyTotals[type]! + entry.amount;
          }
        } else {
          debugPrint('Skipping transaction from different month');
        }
      }

      debugPrint('Final monthly totals: $monthlyTotals');
      return monthlyTotals;
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      
      // Return zero values in case of error
      return {
        'expense': 0.0,
        'income': 0.0,
      };
    }
  }

  @override
  void initState() {
    super.initState();
    // Загружаем категории при старте HomeScreen
    Future.microtask(() {
      final categoriesProvider = Provider.of<CategoriesProvider>(context, listen: false);
      categoriesProvider.loadCategories();
    });
    _userNameFuture = _fetchUserName();
    _transactionsFuture = _fetchTransactions();
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
    setState(() {
      _transactionsFuture = _fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final currentDate = DateTime.now();
    final monthYear = DateFormat('MMMM, yyyy').format(currentDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: _refreshTransactions,
          ),
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
      body: StreamBuilder<AuthUser?>(
        stream: Amplify.Auth.getCurrentUser().asStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            );
          }

          final user = snapshot.data;
          if (user == null) {
            return Center(
              child: Text(
                'Not signed in',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          return FutureBuilder<String>(
            future: _userNameFuture,
            builder: (context, nameSnapshot) {
              String displayUserName;
              if (nameSnapshot.connectionState == ConnectionState.waiting) {
                displayUserName = 'User';
              } else if (nameSnapshot.hasData && nameSnapshot.data!.isNotEmpty) {
                displayUserName = nameSnapshot.data!;
              } else {
                displayUserName = user.username;
              }

              return FutureBuilder<Map<String, double>>(
                future: _transactionsFuture,
                builder: (context, transactionsSnapshot) {
                  double expenseTotal = 0.0;
                  double incomeTotal = 0.0;

                  if (transactionsSnapshot.hasData) {
                    final totals = transactionsSnapshot.data!;
                    expenseTotal = totals['expense'] ?? 0.0;
                    incomeTotal = totals['income'] ?? 0.0;
                  }

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header section with improved typography
                        Text(
                          'Hello, $displayUserName!',
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          monthYear,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurfaceVariant,
                            letterSpacing: 0.15,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Financial Overview Section
                        Text(
                          'Financial Overview',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                            letterSpacing: 0.15,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Income/Expense List
                        Card(
                          elevation: 0,
                          color: colorScheme.surfaceContainerHighest,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              ListItemTile(
                                title: 'Expense',
                                subtitle: transactionsSnapshot.connectionState == ConnectionState.waiting
                                    ? 'Loading...'
                                    : '${expenseTotal.toStringAsFixed(2)} EUR',
                                icon: Icons.trending_down,
                                iconColor: colorScheme.error,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/transactions',
                                    arguments: {
                                      'type': 'expense',
                                      'month': DateTime.now(),
                                    },
                                  );
                                },
                              ),
                              ListItemTile(
                                title: 'Income',
                                subtitle: transactionsSnapshot.connectionState == ConnectionState.waiting
                                    ? 'Loading...'
                                    : '${incomeTotal.toStringAsFixed(2)} EUR',
                                icon: Icons.trending_up,
                                iconColor: colorScheme.primary,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/transactions',
                                    arguments: {
                                      'type': 'income',
                                      'month': DateTime.now(),
                                    },
                                  );
                                },
                                showDivider: false,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Notifications Section
                        Text(
                          'Notifications',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                            letterSpacing: 0.15,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Notifications List
                        Card(
                          elevation: 0,
                          color: colorScheme.surfaceContainerHighest,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListItemTile(
                            title: 'Cafe budget is 90%',
                            subtitle: 'You\'re approaching your monthly limit',
                            icon: Icons.notifications,
                            iconColor: colorScheme.tertiary,
                            onTap: () {
                              // Navigate to budget screen or show budget details
                            },
                            showDivider: false,
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
