import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../src/constants/app_colors.dart';
import '../models/balance.dart';
import '../providers/balances_provider.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../widgets/add_balance_form.dart';
import '../widgets/balance_tile.dart';
import '../services/auth_service.dart';
import '../constants/app_strings.dart';

class BalancesScreen extends StatelessWidget {
  const BalancesScreen({super.key});

  // Extracted AppBar builder
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        AppStrings.balancesTitle,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _showAddBalanceSheet(context),
          tooltip: AppStrings.addBalanceTooltip,
        ),
      ],
    );
  }

  // Extracted loading widget
  Widget _buildLoading() => const Center(child: CircularProgressIndicator());

  // Extracted error widget
  Widget _buildError(String error) => Center(child: Text('${AppStrings.errorPrefix} $error'));

  // Extracted empty state widget
  Widget _buildEmpty(BuildContext context) => Center(
        child: Text(
          AppStrings.noBalances,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
        ),
      );

  // Extracted list builder
  Widget _buildList(BuildContext context, List<Balance> balances) {
    final provider = Provider.of<BalancesProvider>(context, listen: false);
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: balances.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final Balance balance = balances[index];
        return BalanceTile(
          balance: balance,
          onDelete: balance.deletedAt != null ? null : () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete balance?'),
                content: Text('Are you sure you want to delete the balance "${balance.title}"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await provider.deleteBalance(balance.balanceId);
            }
          },
        );
      },
    );
  }

  void _showAddBalanceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return AddBalanceForm();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BalancesProvider>(
      builder: (context, provider, _) {
        debugPrint('BalancesScreen: isLoading=${provider.isLoading}, error=${provider.error}, balancesCount=${provider.balances.length}');
        return Scaffold(
          appBar: _buildAppBar(context),
          backgroundColor: AppColors.background,
          body: () {
            if (provider.isLoading) {
              return _buildLoading();
            }
            if (provider.error != null) {
              return _buildError(provider.error!);
            }
            if (provider.balances.isEmpty) {
              return _buildEmpty(context);
            }
            return _buildList(context, provider.balances);
          }(),
        );
      },
    );
  }
} 