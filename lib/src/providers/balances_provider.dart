import 'package:flutter/material.dart';
import '../models/balance.dart';
import '../services/api_service.dart';

class BalancesProvider extends ChangeNotifier {
  List<Balance> _balances = [];
  bool _isLoading = false;
  String? _error;

  BalancesProvider() {
    debugPrint('[BalancesProvider] constructor called');
  }
  
  List<Balance> get balances => _balances;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBalances() async {
    debugPrint('[BalancesProvider] loadBalances called');
    await _executeAsyncOperation(() async {
      _balances = await ApiService.getBalances();
      debugPrint('[BalancesProvider]: Loaded ${_balances.length} balances');
    });
  }

  Future<void> createBalance({
    required String userId,
    required String groupId,
    required String currency,
    required String title,
    String? description,
  }) async {
    await _executeAsyncOperation(() async {
      final response = await ApiService.postBalance(
        userId: userId,
        groupId: groupId,
        currency: currency,
        title: title,
        description: description,
      );
      
      if (response != null) {
        final newBalance = Balance.fromJson(response);
        _balances.add(newBalance);
        debugPrint('[BalancesProvider]: Added new balance: ${newBalance.title}');
      }
    });
  }

  Future<void> deleteBalance(String balanceId) async {
    if (balanceId.trim().isEmpty) {
      _setError('ID баланса не может быть пустым');
      return;
    }

    await _executeAsyncOperation(() async {
      await ApiService.deleteBalance(balanceId);
      _balances.removeWhere((balance) => balance.balanceId == balanceId);
      debugPrint('[BalancesProvider]: Deleted balance: $balanceId');
    });
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
    debugPrint('[BalancesProvider]: error: $_error');
  }
} 