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

  List<TransactionEntryData> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadEntries() async {
    debugPrint('[TransactionEntriesProvider] loadEntries called');
    await _executeAsyncOperation(() async {
      final response = await ApiService.getTransactions();
      _entries = response.transactionEntries;
      debugPrint('[TransactionEntriesProvider]: Loaded ${_entries.length} entries');
    });
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
    debugPrint('[TransactionEntriesProvider] createTransaction called');
    await _executeAsyncOperation(() async {
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
      debugPrint('[TransactionEntriesProvider]: Created new transaction');
      await loadEntries();
    });
  }

  Future<Map<String, dynamic>?> getTransactionById(String transactionId) async {
    debugPrint('[TransactionEntriesProvider] getTransactionById called');
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final data = await ApiService.getTransactionById(transactionId);
      debugPrint('[TransactionEntriesProvider]: Retrieved transaction: $transactionId');
      _isLoading = false;
      notifyListeners();
      return data;
    } catch (e) {
      _setError(e.toString());
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _executeAsyncOperation(Future<void> Function() operation) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await operation();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _error = error;
    debugPrint('[TransactionEntriesProvider]: error: $_error');
  }
} 