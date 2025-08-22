import 'package:ahorro_ui/src/widgets/adaptive/adaptive_button.dart';
import 'package:ahorro_ui/src/widgets/fragments/transaction_stats/transaction_stats_grouping_selector.dart';
import 'package:ahorro_ui/src/widgets/fragments/transaction_stats/transaction_stats_type_selector.dart';
import 'package:flutter/material.dart';

class TransactionStatsParamSelector extends StatelessWidget {
  final bool showFullscreenButton;

  const TransactionStatsParamSelector({
    super.key,
    this.showFullscreenButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const TransactionStatsTypeSelector(),
          const SizedBox(width: 16),
          const TransactionStatsGroupingSelector(),
          if (showFullscreenButton) ...[
            const Spacer(),
            AdaptiveIconButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/transactions/stats');
              },
              icon: Icons.fullscreen,
              tooltip: 'View Full Screen',
              color: Theme.of(context).colorScheme.primary,
              iconSize: 28,
            ),
          ],
          if (!showFullscreenButton) const Spacer(),
        ],
      ),
    );
  }
}
