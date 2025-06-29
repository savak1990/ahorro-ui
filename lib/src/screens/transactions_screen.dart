import 'package:flutter/material.dart';
import '../widgets/transaction_tile.dart';
import '../services/api_service.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late Future<List<TransactionDisplayData>> _transactionsFuture;
  
  // Date filters
  int? _selectedYear;
  int? _selectedMonth;
  DateTime? _startDate;
  DateTime? _endDate;
  String _dateFilterType = 'month'; // 'month' or 'period'
  
  // Other parameter filters
  String? _selectedAccount;
  String? _selectedType;
  String? _selectedCategory;
  
  // Available values for filters
  Set<int> _availableYears = {};
  Set<int> _availableMonths = {};
  Set<String> _availableAccounts = {};
  Set<String> _availableTypes = {};
  Set<String> _availableCategories = {};

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _fetchTransactions();
  }

  Future<List<TransactionDisplayData>> _fetchTransactions() async {
    try {
      final response = await ApiService.getTransactions();
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      final DateTime filterMonth = args?['month'] ?? DateTime.now();

      debugPrint('Fetched ${response.transactionEntries.length} transaction entries');
      debugPrint('Filtering by month: ${filterMonth.year}-${filterMonth.month}');

      // Group transactions by unique attributes
      final Map<String, List<TransactionEntryData>> groupedTransactions = {};
      
      for (final entry in response.transactionEntries) {
        final key = '${entry.transactionId}_${entry.type}_${entry.balanceTitle}_${entry.balanceCurrency}_${entry.approvedAt.toIso8601String()}_${entry.merchantName}';
        
        if (!groupedTransactions.containsKey(key)) {
          groupedTransactions[key] = [];
        }
        groupedTransactions[key]!.add(entry);
      }

      debugPrint('Grouped into ${groupedTransactions.length} unique transactions');

      // Convert grouped data to display transactions
      final List<TransactionDisplayData> displayTransactions = [];
      
      for (final group in groupedTransactions.values) {
        if (group.isEmpty) continue;
        
        final firstEntry = group.first;
        
        // Check filter only by month (remove type filter)
        final entryDate = firstEntry.transactedAt;
        if (entryDate.year != filterMonth.year || entryDate.month != filterMonth.month) {
          debugPrint('Skipping transaction from different month: ${entryDate.year}-${entryDate.month}');
          continue;
        }

        // Process categories
        final categories = group.map((e) => e.categoryName).toSet();
        final categoryName = categories.length > 1 ? 'Multiple Categories' : categories.first;

        // Sum amounts
        final totalAmount = group.fold(0.0, (sum, entry) => sum + entry.amount);

        // Determine category icon
        IconData categoryIcon = _getCategoryIcon(categoryName);

        debugPrint('Adding transaction: type=${firstEntry.type}, amount=$totalAmount, category=$categoryName, date=${entryDate.day}');

        displayTransactions.add(TransactionDisplayData(
          id: firstEntry.transactionId,
          type: firstEntry.type,
          amount: totalAmount,
          category: categoryName,
          categoryIcon: categoryIcon,
          account: firstEntry.balanceTitle,
          description: firstEntry.merchantName,
          date: firstEntry.transactedAt,
          currency: firstEntry.balanceCurrency,
        ));
      }

      // Sort by date (newest first)
      displayTransactions.sort((a, b) => b.date.compareTo(a.date));

      // Update available values for filters
      _updateAvailableFilterValues(displayTransactions);

      debugPrint('Final display transactions: ${displayTransactions.length}');
      return displayTransactions;
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      return [];
    }
  }

  void _updateAvailableFilterValues(List<TransactionDisplayData> transactions) {
    _availableYears = transactions.map((t) => t.date.year).toSet();
    _availableMonths = transactions.map((t) => t.date.month).toSet();
    _availableAccounts = transactions.map((t) => t.account).toSet();
    _availableTypes = transactions.map((t) => t.type).toSet();
    _availableCategories = transactions.map((t) => t.category).toSet();
  }

  List<TransactionDisplayData> _applyFilters(List<TransactionDisplayData> transactions) {
    return transactions.where((transaction) {
      // Date filter
      if (_dateFilterType == 'month') {
        if (_selectedYear != null && transaction.date.year != _selectedYear) return false;
        if (_selectedMonth != null && transaction.date.month != _selectedMonth) return false;
      } else if (_dateFilterType == 'period') {
        if (_startDate != null && transaction.date.isBefore(_startDate!)) return false;
        if (_endDate != null && transaction.date.isAfter(_endDate!)) return false;
      }
      
      // Account filter
      if (_selectedAccount != null && transaction.account != _selectedAccount) return false;
      
      // Type filter
      if (_selectedType != null && transaction.type != _selectedType) return false;
      
      // Category filter
      if (_selectedCategory != null && transaction.category != _selectedCategory) return false;
      
      return true;
    }).toList();
  }

  // Группировка транзакций по дням
  Map<String, List<TransactionDisplayData>> _groupTransactionsByDate(List<TransactionDisplayData> transactions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));
    
    final Map<String, List<TransactionDisplayData>> grouped = {
      'Today': [],
      'Previous 7 Days': [],
      'Earlier': [],
    };
    
    for (final transaction in transactions) {
      final transactionDate = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
      
      if (transactionDate == today) {
        grouped['Today']!.add(transaction);
      } else if (transactionDate.isAfter(weekAgo) && transactionDate.isBefore(today)) {
        grouped['Previous 7 Days']!.add(transaction);
      } else {
        grouped['Earlier']!.add(transaction);
      }
    }
    
    // Удаляем пустые группы
    grouped.removeWhere((key, value) => value.isEmpty);
    
    return grouped;
  }

  void _showDateFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Date Filter'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Filter type
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'month', label: Text('Month')),
                    ButtonSegment(value: 'period', label: Text('Period')),
                  ],
                  selected: {_dateFilterType},
                  onSelectionChanged: (Set<String> selected) {
                    setState(() {
                      _dateFilterType = selected.first;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                if (_dateFilterType == 'month') ...[
                  // Year selection
                  DropdownButtonFormField<int>(
                    value: _selectedYear,
                    decoration: const InputDecoration(labelText: 'Year'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Years')),
                      ..._availableYears.map((year) => DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value;
                        if (value != null) {
                          // Update available months for selected year
                          _availableMonths = _availableMonths.where((month) {
                            // Here you can add year filtering logic if needed
                            return true;
                          }).toSet();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  
                  // Month selection
                  DropdownButtonFormField<int>(
                    value: _selectedMonth,
                    decoration: const InputDecoration(labelText: 'Month'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Months')),
                      ..._availableMonths.map((month) => DropdownMenuItem(
                        value: month,
                        child: Text(_getMonthName(DateTime(2024, month))),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedMonth = value;
                      });
                    },
                  ),
                ] else ...[
                  // Period selection
                  ListTile(
                    title: const Text('Start Date'),
                    subtitle: Text(_startDate?.toString().split(' ')[0] ?? 'Not selected'),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('End Date'),
                    subtitle: Text(_endDate?.toString().split(' ')[0] ?? 'Not selected'),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _endDate = date;
                        });
                      }
                    },
                  ),
                ],
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _refreshTransactions();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showOtherFiltersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Other Filters'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Account filter
                DropdownButtonFormField<String>(
                  value: _selectedAccount,
                  decoration: const InputDecoration(labelText: 'Account'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Accounts')),
                    ..._availableAccounts.map((account) => DropdownMenuItem(
                      value: account,
                      child: Text(account),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedAccount = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                
                // Type filter
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Types')),
                    ..._availableTypes.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                
                // Category filter
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Categories')),
                    ..._availableCategories.map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _refreshTransactions();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedYear = null;
      _selectedMonth = null;
      _startDate = null;
      _endDate = null;
      _selectedAccount = null;
      _selectedType = null;
      _selectedCategory = null;
    });
    _refreshTransactions();
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'groceries':
      case 'food':
        return Icons.shopping_cart;
      case 'transport':
      case 'taxi':
        return Icons.directions_car;
      case 'cafe':
      case 'restaurant':
        return Icons.local_cafe;
      case 'salary':
      case 'income':
        return Icons.attach_money;
      case 'gift':
        return Icons.card_giftcard;
      case 'multiple categories':
        return Icons.blur_circular;
      default:
        return Icons.category;
    }
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
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final DateTime month = args?['month'] ?? DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Transactions',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: _showDateFilterDialog,
          ),
          IconButton(
            icon: Icon(
              Icons.tune,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: _showOtherFiltersDialog,
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: _refreshTransactions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Show active filters
          if (_hasActiveFilters()) ...[
            Container(
              padding: const EdgeInsets.all(12),
              color: colorScheme.surfaceContainerHighest,
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getActiveFiltersText(),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _clearAllFilters,
                    child: Text(
                      'Clear',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<TransactionDisplayData>>(
              future: _transactionsFuture,
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading transactions',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _refreshTransactions,
                          child: Text(
                            'Retry',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final allTransactions = snapshot.data ?? [];
                final filteredTransactions = _applyFilters(allTransactions);

                if (filteredTransactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _hasActiveFilters() ? 'with current filters' : 'for ${_getMonthName(month)}',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Группируем транзакции по дням
                final groupedTransactions = _groupTransactionsByDate(filteredTransactions);

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  itemCount: groupedTransactions.length * 2, // Заголовок + транзакции для каждой группы
                  itemBuilder: (context, index) {
                    final groupIndex = index ~/ 2;
                    final isHeader = index % 2 == 0;
                    final groupKey = groupedTransactions.keys.elementAt(groupIndex);
                    final groupTransactions = groupedTransactions[groupKey]!;
                    
                    if (isHeader) {
                      // Заголовок группы
                      return Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8, left: 8, right: 8),
                        child: Text(
                          groupKey,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                            letterSpacing: 0.15,
                          ),
                        ),
                      );
                    } else {
                      // Транзакции группы
                      return Column(
                        children: groupTransactions.asMap().entries.map((entry) {
                          final txIndex = entry.key;
                          final tx = entry.value;
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: TransactionTile(
                              type: tx.type,
                              amount: tx.amount,
                              category: tx.category,
                              categoryIcon: tx.categoryIcon,
                              account: tx.account,
                              date: tx.date,
                              description: tx.description,
                              currency: tx.currency,
                              onTap: () {}, // TODO: navigate to details
                            ),
                          );
                        }).toList(),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
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

  bool _hasActiveFilters() {
    return _selectedYear != null ||
           _selectedMonth != null ||
           _startDate != null ||
           _endDate != null ||
           _selectedAccount != null ||
           _selectedType != null ||
           _selectedCategory != null;
  }

  String _getActiveFiltersText() {
    final filters = <String>[];
    
    if (_dateFilterType == 'month') {
      if (_selectedYear != null) filters.add('Year: $_selectedYear');
      if (_selectedMonth != null) filters.add('Month: ${_getMonthName(DateTime(2024, _selectedMonth!))}');
    } else if (_dateFilterType == 'period') {
      if (_startDate != null) filters.add('From: ${_startDate.toString().split(' ')[0]}');
      if (_endDate != null) filters.add('To: ${_endDate.toString().split(' ')[0]}');
    }
    
    if (_selectedAccount != null) filters.add('Account: $_selectedAccount');
    if (_selectedType != null) filters.add('Type: $_selectedType');
    if (_selectedCategory != null) filters.add('Category: $_selectedCategory');
    
    return filters.join(', ');
  }

  String _getMonthName(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[date.month - 1];
  }
}

class TransactionDisplayData {
  final String id;
  final String type;
  final double amount;
  final String category;
  final IconData categoryIcon;
  final String account;
  final String? description;
  final DateTime date;
  final String currency;

  TransactionDisplayData({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.categoryIcon,
    required this.account,
    this.description,
    required this.date,
    required this.currency,
  });
} 