import 'package:flutter/material.dart';
import '../models/date_filter_type.dart';
import '../models/grouping_type.dart';
import '../models/transaction_entry_data.dart';
import '../models/transaction_display_data.dart';
import '../constants/app_strings.dart';
import '../models/category.dart';
import '../models/filter_option.dart';

class TransactionsFilterProvider extends ChangeNotifier {
  // Source data
  List<TransactionEntryData> _entries = [];

  // Filters state
  DateFilterType dateFilterType = DateFilterType.month;
  int? selectedYear;
  int? selectedMonth;
  DateTime? startDate;
  DateTime? endDate;

  final Set<String> selectedTypes = {};
  final Set<String> selectedAccounts = {};
  final Set<String> selectedCategories = {};

  GroupingType groupingType = GroupingType.date;

  // Derived
  Set<int> availableYears = {};
  Set<int> availableMonths = {};
  Set<String> availableAccounts = {};
  Set<String> availableTypes = {};
  Set<String> availableCategories = {};

  void setEntries(List<TransactionEntryData> entries) {
    if (identical(_entries, entries)) {
      return;
    }
    _entries = entries;
    _rebuildAvailableFilters();
    notifyListeners();
  }

  // Public getters
  bool get hasActiveDateFilters => selectedYear != null || selectedMonth != null || startDate != null || endDate != null;
  bool get hasActiveNonDateFilters => selectedTypes.isNotEmpty || selectedAccounts.isNotEmpty || selectedCategories.isNotEmpty;

  // Filter options for sheets
  List<FilterOption> getTypeFilterOptions() {
    final options = <FilterOption>[
      const FilterOption(value: 'all', label: 'All Types', isAllOption: true),
    ];
    for (final type in availableTypes) {
      final icon = type == 'income' ? Icons.trending_up : type == 'expense' ? Icons.trending_down : Icons.swap_horiz;
      final color = type == 'income' ? Colors.green : type == 'expense' ? Colors.red : Colors.blue;
      options.add(FilterOption(
        value: type,
        label: _capitalize(type),
        icon: icon,
        color: color,
        count: _countBy((d) => d.type == type),
      ));
    }
    return options;
  }

  List<FilterOption> getAccountFilterOptions() {
    final options = <FilterOption>[
      const FilterOption(value: 'all', label: 'All Accounts', isAllOption: true),
    ];
    for (final acc in availableAccounts) {
      options.add(FilterOption(
        value: acc,
        label: acc,
        icon: Icons.account_balance,
        count: _countBy((d) => d.account == acc),
      ));
    }
    return options;
  }

  List<FilterOption> getCategoryFilterOptions() {
    final options = <FilterOption>[
      const FilterOption(value: 'all', label: 'All Categories', isAllOption: true),
    ];
    for (final cat in availableCategories) {
      options.add(FilterOption(
        value: cat,
        label: cat,
        icon: Category.getCategoryIcon(cat),
        count: _countBy((d) => d.category == cat),
      ));
    }
    return options;
  }

  // Apply filters and group
  Map<String, List<TransactionDisplayData>> get groupedTransactions {
    final display = _entries.map(_mapEntry).toList();

    final dateFiltered = display.where((tx) {
      if (!hasActiveDateFilters) return true;
      if (dateFilterType == DateFilterType.month) {
        if (selectedYear != null && tx.date.year != selectedYear) return false;
        if (selectedMonth != null && tx.date.month != selectedMonth) return false;
      } else if (dateFilterType == DateFilterType.period) {
        if (startDate != null && tx.date.isBefore(startDate!)) return false;
        if (endDate != null && tx.date.isAfter(endDate!)) return false;
      }
      return true;
    }).toList();

    final filtered = dateFiltered.where((t) {
      if (selectedTypes.isNotEmpty && !selectedTypes.contains(t.type)) return false;
      if (selectedAccounts.isNotEmpty && !selectedAccounts.contains(t.account)) return false;
      if (selectedCategories.isNotEmpty && !selectedCategories.contains(t.category)) return false;
      return true;
    }).toList();

    return _group(filtered);
  }

  // Mutators
  void setGroupingType(GroupingType type) {
    groupingType = type;
    notifyListeners();
  }

  void setDateFilterType(DateFilterType type) {
    dateFilterType = type;
    notifyListeners();
  }

  void setYear(int? year) {
    selectedYear = year;
    notifyListeners();
  }

  void setMonth(int? month) {
    selectedMonth = month;
    notifyListeners();
  }

  void setStartDate(DateTime? date) {
    startDate = date;
    notifyListeners();
  }

  void setEndDate(DateTime? date) {
    endDate = date;
    notifyListeners();
  }

  void clearDateFilters() {
    selectedYear = null;
    selectedMonth = null;
    startDate = null;
    endDate = null;
    notifyListeners();
  }

  void toggleType(String value, bool selected) {
    if (value == 'all') {
      selectedTypes.clear();
    } else {
      if (selected) {
        selectedTypes.add(value);
      } else {
        selectedTypes.remove(value);
      }
    }
    notifyListeners();
  }

  void toggleAccount(String value, bool selected) {
    if (value == 'all') {
      selectedAccounts.clear();
    } else {
      if (selected) {
        selectedAccounts.add(value);
      } else {
        selectedAccounts.remove(value);
      }
    }
    notifyListeners();
  }

  void toggleCategory(String value, bool selected) {
    if (value == 'all') {
      selectedCategories.clear();
    } else {
      if (selected) {
        selectedCategories.add(value);
      } else {
        selectedCategories.remove(value);
      }
    }
    notifyListeners();
  }

  void clearAllFilters() {
    selectedTypes.clear();
    selectedAccounts.clear();
    selectedCategories.clear();
    clearDateFilters();
    notifyListeners();
  }

  void updateSelections({Set<String>? types, Set<String>? accounts, Set<String>? categories}) {
    if (types != null) {
      selectedTypes
        ..clear()
        ..addAll(types);
    }
    if (accounts != null) {
      selectedAccounts
        ..clear()
        ..addAll(accounts);
    }
    if (categories != null) {
      selectedCategories
        ..clear()
        ..addAll(categories);
    }
    notifyListeners();
  }

  // Internals
  void _rebuildAvailableFilters() {
    final display = _entries.map(_mapEntry).toList();
    availableYears = display.map((t) => t.date.year).toSet();
    availableMonths = display.map((t) => t.date.month).toSet();
    availableAccounts = display.map((t) => t.account).toSet();
    availableTypes = display.map((t) => t.type).toSet();
    availableCategories = display.map((t) => t.category).toSet();
  }

  int _countBy(bool Function(TransactionDisplayData) predicate) {
    final display = _entries.map(_mapEntry).toList();
    return display.where(predicate).length;
  }

  TransactionDisplayData _mapEntry(TransactionEntryData entry) {
    return TransactionDisplayData(
      id: entry.transactionId,
      type: entry.type,
      amount: entry.amount,
      category: entry.categoryName,
      categoryIcon: Category.getCategoryIcon(entry.categoryName),
      account: entry.balanceTitle,
      merchantName: entry.merchantName,
      date: entry.transactedAt,
      currency: entry.balanceCurrency,
    );
  }

  Map<String, List<TransactionDisplayData>> _group(List<TransactionDisplayData> txs) {
    if (groupingType == GroupingType.category) {
      final Map<String, List<TransactionDisplayData>> grouped = {};
      for (final t in txs) {
        grouped.putIfAbsent(t.category, () => []).add(t);
      }
      final sortedKeys = grouped.keys.toList()..sort();
      final Map<String, List<TransactionDisplayData>> sorted = {};
      for (final k in sortedKeys) {
        sorted[k] = grouped[k]!;
      }
      return sorted;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));

    final Map<String, List<TransactionDisplayData>> grouped = {
      AppStrings.groupToday: [],
      AppStrings.groupPrevious7Days: [],
      AppStrings.groupEarlier: [],
    };

    for (final t in txs) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      if (d == today) {
        grouped[AppStrings.groupToday]!.add(t);
      } else if (d.isAfter(weekAgo) && d.isBefore(today)) {
        grouped[AppStrings.groupPrevious7Days]!.add(t);
      } else {
        grouped[AppStrings.groupEarlier]!.add(t);
      }
    }

    grouped.removeWhere((key, value) => value.isEmpty);
    return grouped;
  }

  String _capitalize(String value) => value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
}

