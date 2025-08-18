import 'dart:async';

import 'package:ahorro_ui/src/models/currencies.dart';
import 'package:ahorro_ui/src/models/transaction_stats.dart';
import 'package:ahorro_ui/src/services/api_service.dart';
import 'package:flutter/material.dart';

enum TransactionStatsPeriod { year, quarter, month, week, day }

class TransactionStatsProvider extends ChangeNotifier {
  TransactionStatsProvider() {
    // Initialize default values for _startDate and _endDate
    final now = DateTime.now();
    _startDate = DateTime(
      now.year,
      now.month,
      1,
    ); // Beginning of the current month
    _endDate = DateTime(now.year, now.month + 1, 0); // End of the current month
  }

  String? _categoryId;
  String? _balanceId;
  DateTime? _startDate;
  DateTime? _endDate;
  TransactionStatsType _type = TransactionStatsType.expense;
  TransactionStatsGrouping _grouping = TransactionStatsGrouping.categories;
  CurrencyCode _currency = CurrencyCode.eur;
  int _maxItems = 10;

  // Result state
  bool _loading = false;
  Object? _error;
  TransactionStatsResponse? _data;

  Timer? _debounce;
  int _requestToken = 0; // simple in-flight dropper

  bool get loading => _loading;
  Object? get error => _error;
  TransactionStatsResponse? get data => _data;

  // Public manual refresh (pull-to-refresh, retry button, etc.)
  Future<void> refresh() async => _fetch(immediate: true);

  // Debounce to avoid spamming API when user taps quickly
  void _scheduleFetch() {
    debugPrint('Scheduling fetch with debounce');
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      _fetch();
    });
  }

  Future<void> _fetch({bool immediate = false}) async {
    debugPrint(
      'Fetching transaction stats: '
      'start=$_startDate, end=$_endDate, type=$_type, '
      'grouping=$_grouping, currency=$_currency, '
      'categoryId=$_categoryId, balanceId=$_balanceId, maxItems=$_maxItems',
    );

    _debounce?.cancel();
    final token = ++_requestToken; // capture token for this call
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // Call ApiService to fetch transaction stats
      final result = await ApiService.getTransactionStats(
        startDate: _startDate!,
        endDate: _endDate!,
        grouping: _grouping,
        type: _type,
        currency: _currency,
        categoryId: _categoryId,
        balanceId: _balanceId,
        maxItems: _maxItems,
      );

      // Only accept the latest response
      if (token == _requestToken) {
        _data = result;
        _loading = false;
        notifyListeners();
      }
    } catch (e) {
      if (token == _requestToken) {
        _error = e;
        _loading = false;
        notifyListeners();
      }
    }
  }

  set selectedPeriod(TransactionStatsPeriod period) {
    final now = DateTime.now();
    DateTime? newStartDate;
    DateTime? newEndDate;

    switch (period) {
      case TransactionStatsPeriod.year:
        newStartDate = DateTime(now.year - 1, now.month, now.day);
        newEndDate = now;
        break;
      case TransactionStatsPeriod.quarter:
        newStartDate = DateTime(now.year, now.month - 3, now.day);
        newEndDate = now;
        break;
      case TransactionStatsPeriod.month:
        newStartDate = DateTime(now.year, now.month - 1, now.day);
        newEndDate = now;
        break;
      case TransactionStatsPeriod.week:
        newStartDate = now.subtract(const Duration(days: 7));
        newEndDate = now;
        break;
      case TransactionStatsPeriod.day:
        newStartDate = now.subtract(const Duration(days: 1));
        newEndDate = now;
        break;
    }

    // Update only if values have changed
    if (_startDate != newStartDate || _endDate != newEndDate) {
      _startDate = newStartDate;
      _endDate = newEndDate;
      notifyListeners();
    }
  }

  void setSelectedDateRange(DateTime? start, DateTime? end) {
    if (_startDate == start && _endDate == end) return;
    _startDate = start;
    _endDate = end;
    _scheduleFetch();
    notifyListeners();
  }

  set selectedCategoryId(String? id) {
    if (_categoryId == id) return;
    _categoryId = id;
    _scheduleFetch();
    notifyListeners();
  }

  String? get selectedCategoryId => _categoryId;

  set selectedBalanceId(String? id) {
    if (_balanceId == id) return;
    _balanceId = id;
    _scheduleFetch();
    notifyListeners();
  }

  set selectedType(TransactionStatsType type) {
    if (_type == type) return;
    _type = type;
    _scheduleFetch();
    notifyListeners();
  }

  TransactionStatsType get selectedType => _type;

  String get selectedTypeLabel {
    switch (_type) {
      case TransactionStatsType.expense:
        return 'Expense';
      case TransactionStatsType.income:
        return 'Income';
    }
  }

  set selectedGrouping(TransactionStatsGrouping grouping) {
    if (_grouping == grouping) return;
    _grouping = grouping;
    _scheduleFetch();
    notifyListeners();
  }

  TransactionStatsGrouping get selectedGrouping => _grouping;

  set selectedCurrency(CurrencyCode currency) {
    if (_currency == currency) return;
    _currency = currency;
    _scheduleFetch();
    notifyListeners();
  }

  CurrencyCode get selectedCurrency => _currency;

  set selectedMaxItems(int maxItems) {
    if (_maxItems == maxItems) return;
    _maxItems = maxItems;
    _scheduleFetch();
    notifyListeners();
  }

  int get selectedMaxItems => _maxItems;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
