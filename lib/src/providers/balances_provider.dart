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
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
} 