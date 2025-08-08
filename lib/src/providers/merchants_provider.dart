import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/merchant.dart';
import 'base_provider.dart';

class MerchantsProvider extends BaseProvider {
  MerchantsProvider();

  List<Merchant> _merchants = [];
  static const Duration _cacheDuration = Duration(minutes: 60);

  List<Merchant> get merchants => _merchants;
  String? get error => errorMessage;

  Future<void> loadMerchants({bool forceRefresh = false}) async {
    if (!forceRefresh && !shouldRefresh(_cacheDuration) && _merchants.isNotEmpty) {
      return;
    }
    await execute(() async {
      _merchants = await ApiService.getMerchants();
      debugPrint('[MerchantsProvider]: Loaded ${_merchants.length} merchants');
    });
  }

  Future<Merchant?> createMerchant({required String name, required String userId}) async {
    try {
      final merchant = await ApiService.postMerchant(name: name, userId: userId);
      _merchants.insert(0, merchant);
      debugPrint('[MerchantsProvider]: Created new merchant: ${merchant.name}');
      notifyListeners();
      return merchant;
    } catch (e) {
      setErrorMessage(e.toString());
      notifyListeners();
      return null;
    }
  }
} 