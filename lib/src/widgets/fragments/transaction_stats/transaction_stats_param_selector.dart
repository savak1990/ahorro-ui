import 'package:ahorro_ui/src/widgets/fragments/transaction_stats/transaction_stats_grouping_selector.dart';
import 'package:ahorro_ui/src/widgets/fragments/transaction_stats/transaction_stats_type_selector.dart';
import 'package:flutter/material.dart';

class TransactionStatsParamSelector extends StatelessWidget {
  const TransactionStatsParamSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        TransactionStatsTypeSelector(),
        Spacer(),
        TransactionStatsGroupingSelector(),
      ],
    );
  }
}
