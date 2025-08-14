import 'package:flutter/material.dart';
import '../models/balance.dart';
import '../services/api_service.dart';
import 'base_provider.dart';

class BalancesProvider extends BaseProvider {
  BalancesProvider();

  List<Balance> _balances = [];
  static const Duration _cacheDuration = Duration(minutes: 60);

  /// Возвращает только активные балансы (без deletedAt)
  List<Balance> get balances =>
      _balances.where((balance) => balance.deletedAt == null).toList();

  /// Возвращает все балансы (включая удаленные) - для отладки
  List<Balance> get allBalances => _balances;

  String? get error => errorMessage;

  Future<void> loadBalances({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        !shouldRefresh(_cacheDuration) &&
        _balances.isNotEmpty) {
      return;
    }
    await execute(() async {
      _balances = await ApiService.getBalances();
      final activeBalances =
          _balances.where((balance) => balance.deletedAt == null).length;
      debugPrint(
          '[BalancesProvider]: Loaded ${_balances.length} balances total, $activeBalances active');
    });
  }

  void clearData() {
    _balances = [];
    notifyListeners();
  }

  Future<void> createBalance({
    required String userId,
    required String groupId,
    required String currency,
    required String title,
    String? description,
  }) async {
    await execute(() async {
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
        debugPrint(
            '[BalancesProvider]: Added new balance: ${newBalance.title}');
      }
    });
  }

  Future<void> deleteBalance(String balanceId) async {
    if (balanceId.trim().isEmpty) {
      setErrorMessage('ID баланса не может быть пустым');
      return;
    }

    await execute(() async {
      await ApiService.deleteBalance(balanceId);
      _balances.removeWhere((balance) => balance.balanceId == balanceId);
      debugPrint('[BalancesProvider]: Deleted balance: $balanceId');
    });
  }
}
