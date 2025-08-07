import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/merchant.dart';

class MerchantsProvider extends ChangeNotifier {
  List<Merchant> _merchants = [];
  bool _isLoading = false;
  String? _error;

  MerchantsProvider() {
    debugPrint('[MerchantsProvider] constructor called');
  }

  List<Merchant> get merchants => _merchants;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMerchants() async {
    debugPrint('[MerchantsProvider] loadMerchants called');
    await _executeAsyncOperation(() async {
      _merchants = await ApiService.getMerchants();
      debugPrint('[MerchantsProvider]: Loaded ${_merchants.length} merchants');
    });
  }

  Future<Merchant?> createMerchant({required String name, required String userId}) async {
    debugPrint('[MerchantsProvider] createMerchant called');
    await _executeAsyncOperation(() async {
      final merchant = await ApiService.postMerchant(name: name, userId: userId);
      _merchants.insert(0, merchant);
      debugPrint('[MerchantsProvider]: Created new merchant: ${merchant.name}');
    });
    return _merchants.isNotEmpty ? _merchants.first : null;
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
    debugPrint('[MerchantsProvider]: error: $_error');
  }
} 