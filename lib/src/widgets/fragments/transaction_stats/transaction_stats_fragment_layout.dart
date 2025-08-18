import 'package:ahorro_ui/src/widgets/fragments/transaction_stats/transaction_stats_chart.dart';
import 'package:ahorro_ui/src/widgets/fragments/transaction_stats/transaction_stats_param_selector.dart';
import 'package:flutter/material.dart';

class TransactionStatsFragmentLayout extends StatelessWidget {
  const TransactionStatsFragmentLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TransactionStatsParamSelector(),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
            child: const TransactionStatsChart(),
          ),
        ),
      ],
    );
  }
}
