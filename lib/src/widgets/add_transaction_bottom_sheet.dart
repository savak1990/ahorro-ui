import 'package:flutter/material.dart';
import 'package:ahorro_ui/src/screens/add_transaction_screen.dart';

Future<T?> showAddTransactionBottomSheet<T>(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: cs.surfaceContainerHigh,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => const AddTransactionScreen(),
  );
}