import 'package:flutter/material.dart';
import '../widgets/transaction_tile.dart';
import '../models/filter_option.dart';
import '../services/api_service.dart';
import 'add_transaction_screen.dart';
import '../widgets/date_filter_bottom_sheet.dart';
import 'package:ahorro_ui/src/widgets/filters_bottom_sheet.dart';
import '../models/transaction_entry_data.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late Future<List<TransactionDisplayData>> _transactionsFuture;
  List<TransactionDisplayData> _allTransactions = [];
  
  // Date filters
  int? _selectedYear;
  int? _selectedMonth;
  DateTime? _startDate;
  DateTime? _endDate;
  String _dateFilterType = 'month'; // 'month' or 'period'
  
  // New chip-based filters
  Set<String> _selectedTypes = {};
  Set<String> _selectedAccounts = {};
  Set<String> _selectedCategories = {};
  
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
        
        // Process categories
        final categories = group.map((e) => e.categoryName).toSet();
        final categoryName = categories.length > 1 ? 'Multiple Categories' : categories.first;

        // Sum amounts
        final totalAmount = group.fold(0.0, (sum, entry) => sum + entry.amount);

        // Determine category icon
        IconData categoryIcon = _getCategoryIcon(categoryName);

        displayTransactions.add(TransactionDisplayData(
          id: firstEntry.transactionId,
          type: firstEntry.type,
          amount: totalAmount,
          category: categoryName,
          categoryIcon: categoryIcon,
          account: firstEntry.balanceTitle,
          merchantName: firstEntry.merchantName,
          date: firstEntry.transactedAt,
          currency: firstEntry.balanceCurrency,
        ));
      }

      // Сохраняем все транзакции для фильтров
      _allTransactions = displayTransactions;
      // Формируем фильтры по годам и месяцам на основе всех транзакций
      _updateAvailableFilterValues(_allTransactions);

      // Применяем фильтры по дате только если они активны
      final filtered = displayTransactions.where((tx) {
        // Если есть активные фильтры по дате, применяем их
        if (_hasActiveDateFilters()) {
          debugPrint('Applying date filters: type=$_dateFilterType, year=$_selectedYear, month=$_selectedMonth');
          if (_dateFilterType == 'month') {
            if (_selectedYear != null && tx.date.year != _selectedYear) return false;
            if (_selectedMonth != null && tx.date.month != _selectedMonth) return false;
          } else if (_dateFilterType == 'period') {
            if (_startDate != null && tx.date.isBefore(_startDate!)) return false;
            if (_endDate != null && tx.date.isAfter(_endDate!)) return false;
          }
        } else {
          debugPrint('No active date filters, showing all transactions');
        }
        // Если нет активных фильтров по дате, показываем все транзакции
        return true;
      }).toList();

      debugPrint('Final display transactions: ${filtered.length}');
      return filtered;
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
      // Type filter
      if (_selectedTypes.isNotEmpty && !_selectedTypes.contains(transaction.type)) return false;
      
      // Account filter
      if (_selectedAccounts.isNotEmpty && !_selectedAccounts.contains(transaction.account)) return false;
      
      // Category filter
      if (_selectedCategories.isNotEmpty && !_selectedCategories.contains(transaction.category)) return false;
      
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

  void _showDateFilterBottomSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DateFilterBottomSheet(
        initialFilterType: _dateFilterType,
        initialYear: _selectedYear,
        initialMonth: _selectedMonth,
        initialStartDate: _startDate,
        initialEndDate: _endDate,
        availableYears: _availableYears,
      ),
    );

    if (result != null) {
      setState(() {
        _dateFilterType = result['filterType'];
        _selectedYear = result['year'];
        _selectedMonth = result['month'];
        _startDate = result['startDate'];
        _endDate = result['endDate'];
      });
      _refreshTransactions();
    }
  }

  void _onTypeFilterChanged(String value, bool selected) {
    setState(() {
      if (value == 'all') {
        _selectedTypes.clear();
      } else {
        if (selected) {
          _selectedTypes.add(value);
        } else {
          _selectedTypes.remove(value);
        }
      }
    });
  }

  void _onAccountFilterChanged(String value, bool selected) {
    setState(() {
      if (value == 'all') {
        _selectedAccounts.clear();
      } else {
        if (selected) {
          _selectedAccounts.add(value);
        } else {
          _selectedAccounts.remove(value);
        }
      }
    });
  }

  void _onCategoryFilterChanged(String value, bool selected) {
    setState(() {
      if (value == 'all') {
        _selectedCategories.clear();
      } else {
        if (selected) {
          _selectedCategories.add(value);
        } else {
          _selectedCategories.remove(value);
        }
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      _selectedYear = null;
      _selectedMonth = null;
      _startDate = null;
      _endDate = null;
      _selectedTypes.clear();
      _selectedAccounts.clear();
      _selectedCategories.clear();
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

  List<FilterOption> _getTypeFilterOptions() {
    final options = <FilterOption>[
      const FilterOption(
        value: 'all',
        label: 'All Types',
        isAllOption: true,
      ),
    ];

    for (final type in _availableTypes) {
      final icon = type == 'income' ? Icons.trending_up : 
                   type == 'expense' ? Icons.trending_down : 
                   Icons.swap_horiz;
      final color = type == 'income' ? Colors.green : 
                    type == 'expense' ? Colors.red : 
                    Colors.blue;
      
      options.add(FilterOption(
        value: type,
        label: type.capitalize(),
        icon: icon,
        color: color,
        count: _getTransactionCountByType(type),
      ));
    }

    return options;
  }

  List<FilterOption> _getAccountFilterOptions() {
    final options = <FilterOption>[
      const FilterOption(
        value: 'all',
        label: 'All Accounts',
        isAllOption: true,
      ),
    ];

    for (final account in _availableAccounts) {
      options.add(FilterOption(
        value: account,
        label: account,
        icon: Icons.account_balance,
        count: _getTransactionCountByAccount(account),
      ));
    }

    return options;
  }

  List<FilterOption> _getCategoryFilterOptions() {
    final options = <FilterOption>[
      const FilterOption(
        value: 'all',
        label: 'All Categories',
        isAllOption: true,
      ),
    ];

    for (final category in _availableCategories) {
      options.add(FilterOption(
        value: category,
        label: category,
        icon: _getCategoryIcon(category),
        count: _getTransactionCountByCategory(category),
      ));
    }

    return options;
  }

  int _getTransactionCountByType(String type) {
    // Пока возвращаем 0, так как подсчет требует доступа к текущим данным
    // В будущем можно добавить кэширование результатов
    return 0;
  }

  int _getTransactionCountByAccount(String account) {
    // Пока возвращаем 0, так как подсчет требует доступа к текущим данным
    // В будущем можно добавить кэширование результатов
    return 0;
  }

  int _getTransactionCountByCategory(String category) {
    // Пока возвращаем 0, так как подсчет требует доступа к текущим данным
    // В будущем можно добавить кэширование результатов
    return 0;
  }

  void _showFiltersBottomSheet() async {
    final result = await showModalBottomSheet<Map<String, Set<String>>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => FiltersBottomSheet(
        typeOptions: _getTypeFilterOptions(),
        accountOptions: _getAccountFilterOptions(),
        categoryOptions: _getCategoryFilterOptions(),
        initialSelectedTypes: _selectedTypes,
        initialSelectedAccounts: _selectedAccounts,
        initialSelectedCategories: _selectedCategories,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedTypes = result['types'] ?? {};
        _selectedAccounts = result['accounts'] ?? {};
        _selectedCategories = result['categories'] ?? {};
      });
    }
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
              Icons.tune,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: _showFiltersBottomSheet,
          ),
          IconButton(
            icon: Icon(
              Icons.calendar_today,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: _showDateFilterBottomSheet,
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
          // Отображаем активные фильтры
          if (_hasActiveNonDateFilters()) _buildActiveFiltersSummary(),
          if (_hasActiveDateFilters()) _buildActiveDateFiltersSummary(),
          
          const SizedBox(height: 8),
          
          // Transactions list
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
                              merchantName: tx.merchantName,
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
    return _selectedTypes.isNotEmpty ||
           _selectedAccounts.isNotEmpty ||
           _selectedCategories.isNotEmpty;
  }

  String _getMonthName(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[date.month - 1];
  }

  bool _hasActiveDateFilters() {
    final hasActive = _selectedYear != null ||
           _selectedMonth != null ||
           _startDate != null ||
           _endDate != null;
    debugPrint('_hasActiveDateFilters: year=$_selectedYear, month=$_selectedMonth, start=$_startDate, end=$_endDate, result=$hasActive');
    return hasActive;
  }

  String _getActiveDateFiltersText() {
    final filters = <String>[];
    
    if (_dateFilterType == 'month') {
      if (_selectedYear != null) filters.add('Year: $_selectedYear');
      if (_selectedMonth != null) filters.add('Month: ${_getMonthName(DateTime(2024, _selectedMonth!))}');
    } else if (_dateFilterType == 'period') {
      if (_startDate != null) filters.add('Start: ${_startDate.toString().split(' ')[0]}');
      if (_endDate != null) filters.add('End: ${_endDate.toString().split(' ')[0]}');
    }
    
    return filters.join(', ');
  }

  void _clearDateFilters() {
    setState(() {
      _selectedYear = null;
      _selectedMonth = null;
      _startDate = null;
      _endDate = null;
    });
    _refreshTransactions();
  }

  bool _hasActiveNonDateFilters() {
    return _selectedTypes.isNotEmpty ||
           _selectedAccounts.isNotEmpty ||
           _selectedCategories.isNotEmpty;
  }

  Widget _buildActiveFiltersSummary() {
    // Этот метод будет создавать виджет для отображения активных фильтров
    final filters = <String>[];
    if (_selectedTypes.isNotEmpty) filters.add('Type: ${_selectedTypes.map((t) => t.capitalize()).join(', ')}');
    if (_selectedAccounts.isNotEmpty) filters.add('Balance: ${_selectedAccounts.join(', ')}');
    if (_selectedCategories.isNotEmpty) filters.add('Category: ${_selectedCategories.join(', ')}');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
      child: Row(
        children: [
          Icon(Icons.filter_list, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(filters.join(' • '), overflow: TextOverflow.ellipsis)),
          TextButton(
            onPressed: _clearAllFilters,
            child: Text('Clear'),
          )
        ],
      ),
    );
  }

  Widget _buildActiveDateFiltersSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(_getActiveDateFiltersText())),
          TextButton(
            onPressed: _clearDateFilters,
            child: Text('Clear'),
          )
        ],
      ),
    );
  }
}

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
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
  final String? merchantName;
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
    this.merchantName,
    required this.date,
    required this.currency,
  });
} 