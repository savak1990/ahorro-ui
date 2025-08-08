import 'package:flutter/material.dart';
import '../providers/transaction_entries_provider.dart';
import '../providers/categories_provider.dart';
import '../providers/merchants_provider.dart';
import '../providers/balances_provider.dart';
import '../providers/amplify_provider.dart';

class AppStateProvider extends ChangeNotifier {
  final AmplifyProvider _amplify;
  final TransactionEntriesProvider _transactions;
  final CategoriesProvider _categories;
  final MerchantsProvider _merchants;
  final BalancesProvider _balances;

    AppStateProvider()
      : _amplify = AmplifyProvider(),
        _transactions = TransactionEntriesProvider(),
        _categories = CategoriesProvider(),
        _merchants = MerchantsProvider(),
        _balances = BalancesProvider();

  AmplifyProvider get amplify => _amplify;
  TransactionEntriesProvider get transactions => _transactions;
  CategoriesProvider get categories => _categories;
  MerchantsProvider get merchants => _merchants;
  BalancesProvider get balances => _balances;

  Future<void> initializeApp(String amplifyconfig) async {
    await _amplify.configure(amplifyconfig);
    await Future.wait([
      _categories.loadCategories(),
      _balances.loadBalances(),
      _merchants.loadMerchants(),
      _transactions.loadEntries(),
    ]);
  }

  Future<void> refreshAllData() async {
    await Future.wait([
      _categories.loadCategories(forceRefresh: true),
      _balances.loadBalances(forceRefresh: true),
      _merchants.loadMerchants(forceRefresh: true),
      _transactions.loadEntries(forceRefresh: true),
    ]);
  }
    
  bool get isAnyLoading => 
    _transactions.isLoading || 
    _categories.isLoading || 
    _merchants.isLoading || 
    _balances.isLoading ||
    _amplify.isLoading;

  String? get firstError => 
    _amplify.errorMessage ??
    _transactions.errorMessage ?? 
    _categories.errorMessage ?? 
    _merchants.errorMessage ?? 
    _balances.errorMessage;

  @override
  void dispose() {
    _transactions.dispose();
    _categories.dispose();
    _merchants.dispose();
    _balances.dispose();
    _amplify.dispose();
    super.dispose();
  }
}