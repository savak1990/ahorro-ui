import 'package:ahorro_ui/src/models/transaction_stats.dart';
import 'package:ahorro_ui/src/providers/transaction_stats_provider.dart';
import 'package:ahorro_ui/src/widgets/adaptive/adaptive_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionStatsGroupingSelector extends StatelessWidget {
  const TransactionStatsGroupingSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<TransactionStatsProvider, TransactionStatsGrouping>(
      selector: (_, provider) => provider.selectedGrouping,
      builder: (_, selectedGrouping, _) {
        return AdaptiveDropdown<TransactionStatsGrouping>(
          items: TransactionStatsGrouping.values,
          selectedItem: selectedGrouping,
          onChanged: (value) {
            if (value != null) {
              context.read<TransactionStatsProvider>().selectedGrouping = value;
            }
          },
          itemLabelBuilder: (item) {
            switch (item) {
              case TransactionStatsGrouping.category:
                return 'By Category';
              case TransactionStatsGrouping.month:
                return 'By Month';
              case TransactionStatsGrouping.week:
                return 'By Week';
              case TransactionStatsGrouping.day:
                return 'By Day';
              case TransactionStatsGrouping.balance:
                return 'By Balance';
              case TransactionStatsGrouping.currency:
                return 'By Currency';
              case TransactionStatsGrouping.quarter:
                return 'By Quarter';
            }
          },
        );
      },
    );
  }
}
