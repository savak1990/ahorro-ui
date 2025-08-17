import 'package:ahorro_ui/src/models/transaction_stats.dart';
import 'package:ahorro_ui/src/providers/transaction_stats_provider.dart';
import 'package:ahorro_ui/src/widgets/adaptive/adaptive_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionStatsGroupingSelector extends StatelessWidget {
  const TransactionStatsGroupingSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Selector<TransactionStatsProvider, TransactionStatsGrouping>(
        selector: (_, provider) => provider.selectedGrouping,
        builder: (_, selectedGrouping, _) {
          return AdaptiveDropdown<TransactionStatsGrouping>(
            items: TransactionStatsGrouping.values,
            selectedItem: selectedGrouping,
            onChanged: (value) {
              if (value != null) {
                context.read<TransactionStatsProvider>().selectedGrouping =
                    value;
              }
            },
            itemLabelBuilder: (item) {
              switch (item) {
                case TransactionStatsGrouping.categories:
                  return 'Categories';
                case TransactionStatsGrouping.month:
                  return 'Month';
                case TransactionStatsGrouping.week:
                  return 'Week';
                case TransactionStatsGrouping.day:
                  return 'Day';
                case TransactionStatsGrouping.balance:
                  return 'Balance';
              }
            },
          );
        },
      ),
    );
  }
}
