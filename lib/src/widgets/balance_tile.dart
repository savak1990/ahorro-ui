import 'package:flutter/material.dart';
import '../models/balance.dart';
import '../constants/app_colors.dart';

class BalanceTile extends StatelessWidget {
  final Balance balance;
  const BalanceTile({required this.balance, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(Icons.account_balance_wallet, color: AppColors.primary),
        title: Text(
          balance.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(balance.currency, style: Theme.of(context).textTheme.bodyMedium),
        onTap: () {
          // TODO: navigate to balance details
        },
      ),
    );
  }
} 