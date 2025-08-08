import 'package:flutter/material.dart';
import '../models/transaction_display_data.dart';
import 'transaction_tile.dart';
import 'typography.dart';

class GroupedTransactionsSliver extends StatelessWidget {
  final Map<String, List<TransactionDisplayData>> groupedTransactions;
  final void Function(TransactionDisplayData) onTapTransaction;

  const GroupedTransactionsSliver({
    super.key,
    required this.groupedTransactions,
    required this.onTapTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final groupIndex = index ~/ 2;
          final isHeader = index % 2 == 0;
          final groupKey = groupedTransactions.keys.elementAt(groupIndex);
          final groupItems = groupedTransactions[groupKey]!;

          if (isHeader) {
            return TitleEmphasizedLarge(
              text: groupKey,
              padding: const EdgeInsets.only(top: 16, bottom: 8),
            );
          } else {
            return Column(
              children: groupItems.asMap().entries.map((entry) {
                final txIndex = entry.key;
                final tx = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    left: 0,
                    right: 0,
                    top: txIndex == 0 ? 0 : 0,
                    bottom: txIndex == groupItems.length - 1 ? 0 : 0,
                  ),
                  child: TransactionTile(
                    type: tx.type,
                    amount: tx.amount,
                    category: tx.category,
                    categoryIcon: tx.categoryIcon,
                    balance: tx.account,
                    date: tx.date,
                    description: tx.description,
                    merchantName: tx.merchantName,
                    currency: tx.currency,
                    isFirst: txIndex == 0,
                    isLast: txIndex == groupItems.length - 1,
                    onTap: () => onTapTransaction(tx),
                  ),
                );
              }).toList(),
            );
          }
        },
        childCount: groupedTransactions.length * 2,
      ),
    );
  }
}

