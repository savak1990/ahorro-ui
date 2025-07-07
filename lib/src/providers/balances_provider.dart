import 'package:flutter/material.dart';
import '../models/balance.dart';
import '../services/api_service.dart';

class BalancesProvider extends ChangeNotifier {
  List<Balance> _balances = [];
  bool _isLoading = false;
  String? _error;

  List<Balance> get balances => _balances;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBalances() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _balances = await ApiService.getBalances();
      debugPrint('BalancesProvider: Loaded ${_balances.length} balances');
      for (final balance in _balances) {
        //debugPrint('BalancesProvider: Balance - ${balance.title} (${balance.balanceId})');
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('BalancesProvider: Error loading balances - $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createBalance({
    required String userId,
    required String groupId,
    required String currency,
    required String title,
    String? description,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await ApiService.postBalance(
        userId: userId,
        groupId: groupId,
        currency: currency,
        title: title,
        description: description,
      );
      await loadBalances(); // Ждём подтверждения от сервера
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
} 