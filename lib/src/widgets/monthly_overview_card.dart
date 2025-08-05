import 'package:flutter/material.dart';
import '../models/transaction_entry_data.dart';
import '../constants/app_colors.dart';
import 'list_item_tile.dart';

class MonthlyOverviewCard extends StatelessWidget {
  final List<TransactionEntryData> entries;
  final void Function(String type)? onTap;

  const MonthlyOverviewCard({
    Key? key,
    required this.entries,
    this.onTap,
  }) : super(key: key);

  Map<String, double> _calculateMonthlyTotals(List<TransactionEntryData> entries) {
    final currentMonth = DateTime.now();
    final Map<String, double> monthlyTotals = {
      'expense': 0.0,
      'income': 0.0,
    };
    for (final entry in entries) {
      final entryDate = entry.transactedAt;
      if (entryDate.year == currentMonth.year && entryDate.month == currentMonth.month) {
        final type = entry.type.toLowerCase();
        if (monthlyTotals.containsKey(type)) {
          monthlyTotals[type] = monthlyTotals[type]! + entry.amount;
        }
      }
    }
    return monthlyTotals;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final monthlyTotals = _calculateMonthlyTotals(entries);
    return Card(
      elevation: 0,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16)
      ),
      child: Column(
        children: [
          ListItemTile(
            title: 'Expense',
            subtitle: '${monthlyTotals['expense']?.toStringAsFixed(2) ?? '0.00'} EUR',
            icon: Icons.trending_down,
            iconColor: AppColors.danger,
            onTap: onTap != null ? () => onTap!('expense') : null,
          ),
          ListItemTile(
            title: 'Income',
            subtitle: '${monthlyTotals['income']?.toStringAsFixed(2) ?? '0.00'} EUR',
            icon: Icons.trending_up,
            iconColor: AppColors.success,
            onTap: onTap != null ? () => onTap!('income') : null,
            showDivider: false,
          ),
        ],
      ),
    );
  }
} 