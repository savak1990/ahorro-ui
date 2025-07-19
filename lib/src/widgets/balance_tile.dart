import 'package:flutter/material.dart';
import '../models/balance.dart';
import '../constants/app_colors.dart';

class BalanceTile extends StatelessWidget {
  final Balance balance;
  final VoidCallback? onDelete;
  const BalanceTile({required this.balance, this.onDelete, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDeleted = balance.deletedAt != null;
    return Opacity(
      opacity: isDeleted ? 0.5 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          leading: Icon(Icons.account_balance_wallet, color: AppColors.primary),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  balance.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    decoration: isDeleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              if (isDeleted)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'deleted',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Text(balance.currency, style: Theme.of(context).textTheme.bodyMedium),
          trailing: isDeleted
              ? null
              : IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  tooltip: 'Delete',
                  onPressed: onDelete,
                ),
          onTap: () {
            // TODO: navigate to balance details
          },
        ),
      ),
    );
  }
} 