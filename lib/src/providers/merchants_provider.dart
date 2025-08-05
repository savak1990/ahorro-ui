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
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _merchants = await ApiService.getMerchants();
      debugPrint('[MerchantsProvider] loaded ${_merchants.length} merchants');
    } catch (e) {
      _error = e.toString();
      debugPrint('[MerchantsProvider] error: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Merchant?> createMerchant({required String name, required String userId}) async {
    try {
      final merchant = await ApiService.postMerchant(name: name, userId: userId);
      _merchants.insert(0, merchant);
      notifyListeners();
      return merchant;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
} 