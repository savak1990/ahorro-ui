import 'package:flutter/material.dart';
import '../models/transaction_entry_data.dart';
import '../services/api_service.dart';
import '../models/transaction_type.dart';
import '../models/transaction_entry.dart';

class TransactionEntriesProvider extends ChangeNotifier {
  List<TransactionEntryData> _entries = [];
  bool _isLoading = false;
  String? _error;

  TransactionEntriesProvider() {
    debugPrint('[TransactionEntriesProvider] constructor called');
  }

  List<TransactionEntryData> get entries {
    debugPrint('[TransactionEntriesProvider] get entries: ${_entries.length}');
    return _entries;
  }
  bool get isLoading {
    debugPrint('[TransactionEntriesProvider] get isLoading: $_isLoading');
    return _isLoading;
  }
  String? get error {
    debugPrint('[TransactionEntriesProvider] get error: $_error');
    return _error;
  }

  Future<void> loadEntries() async {
    debugPrint('[TransactionEntriesProvider] loadEntries called');
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await ApiService.getTransactions();
      _entries = response.transactionEntries;
      debugPrint('[TransactionEntriesProvider] loaded ${_entries.length} entries');
    } catch (e) {
      _error = e.toString();
      debugPrint('[TransactionEntriesProvider] error: $_error');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createTransaction({
    required TransactionType type,
    double? amount,
    required DateTime date,
    required String categoryId,
    required String balanceId,
    String? description,
    String? merchant,
    List<TransactionEntry>? transactionEntriesParam,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await ApiService.postTransaction(
        type: type,
        amount: amount,
        date: date,
        categoryId: categoryId,
        balanceId: balanceId,
        description: description,
        merchant: merchant,
        transactionEntriesParam: transactionEntriesParam,
      );
      await loadEntries();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getTransactionById(String transactionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiService.getTransactionById(transactionId);
      _isLoading = false;
      notifyListeners();
      return data;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
} 