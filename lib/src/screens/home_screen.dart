import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '../constants/app_colors.dart';
import '../services/api_service.dart';
import 'add_transaction_screen.dart';

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
    final currentDate = DateTime.now();
    final monthYear = DateFormat('MMMM, yyyy').format(currentDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTransactions,
          ),
          IconButton(
            icon: const Icon(Icons.person),
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
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            );
          }

          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('Not signed in'));
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
                        Text(
                          'Hello, $displayUserName!',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          monthYear,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(8),
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
                                  splashColor: theme.colorScheme.primary.withOpacity(0.1),
                                  hoverColor: theme.colorScheme.primary.withOpacity(0.05),
                                  mouseCursor: SystemMouseCursors.click,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Expense',
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            transactionsSnapshot.connectionState == ConnectionState.waiting
                                                ? 'Loading...'
                                                : '${expenseTotal.toStringAsFixed(2)} EUR',
                                            style: theme.textTheme.titleLarge?.copyWith(
                                              color: theme.colorScheme.error,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  borderRadius: BorderRadius.circular(8),
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
                                  splashColor: theme.colorScheme.primary.withOpacity(0.1),
                                  hoverColor: theme.colorScheme.primary.withOpacity(0.05),
                                  mouseCursor: SystemMouseCursors.click,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Income',
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            transactionsSnapshot.connectionState == ConnectionState.waiting
                                                ? 'Loading...'
                                                : '${incomeTotal.toStringAsFixed(2)} EUR',
                                            style: theme.textTheme.titleLarge?.copyWith(
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Notifications',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cafe budget is 90%',
                          style: theme.textTheme.bodyLarge,
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
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
