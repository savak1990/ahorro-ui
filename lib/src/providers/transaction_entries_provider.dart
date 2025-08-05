import 'package:flutter/material.dart';
import '../models/transaction_entry_data.dart';
import '../services/api_service.dart';
import '../models/transaction_type.dart';
import '../models/transaction_entry.dart';

class TransactionEntriesProvider extends ChangeNotifier {
  List<TransactionEntryData> _entries = [];
  bool _isLoading = false;
  String? _error;

  List<TransactionEntryData> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadEntries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await ApiService.getTransactions();
      _entries = response.transactionEntries;
      // Логируем merchantName для всех транзакций
      for (final entry in _entries) {
        //debugPrint('[TransactionEntriesProvider] transactionId: ${entry.transactionId}, type: ${entry.type}, merchantName: ${entry.name}');
      }
    } catch (e) {
      _error = e.toString();
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