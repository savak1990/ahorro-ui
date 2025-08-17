import 'package:ahorro_ui/src/providers/transaction_stats_provider.dart';
import 'package:ahorro_ui/src/widgets/fragments/transaction_stats/transaction_stats_fragment_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionStatsFragment extends StatelessWidget {
  const TransactionStatsFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final model = TransactionStatsProvider();
        // Kick off the initial fetch
        Future.microtask(model.refresh);
        return model;
      },
      child: const TransactionStatsFragmentLayout(),
    );
  }
}
