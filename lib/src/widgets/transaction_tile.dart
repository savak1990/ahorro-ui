import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  final String type; // 'income', 'expense', 'movement'
  final double amount;
  final String category;
  final IconData categoryIcon;
  final String account;
  final DateTime date;
  final String? description;
  final String currency;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.type,
    required this.amount,
    required this.category,
    required this.categoryIcon,
    required this.account,
    required this.date,
    this.description,
    this.currency = 'EUR',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = type == 'expense';
    final isIncome = type == 'income';
    final amountColor = isExpense ? Colors.red : Colors.green;
    return Card(
      color: Colors.grey.shade100,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        splashColor: Colors.grey.withOpacity(0.15),
        highlightColor: Colors.grey.withOpacity(0.08),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Date
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    date.day.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Text(
                    _monthShort(date),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Category icon
              Icon(categoryIcon, size: 28, color: Colors.black),
              const SizedBox(width: 16),
              // Category, account, description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      account,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    if (description != null && description!.isNotEmpty)
                      Text(
                        description!,
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount.toStringAsFixed(2),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: amountColor,
                    ),
                  ),
                  Text(
                    currency,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: amountColor,
                    ),
                  ),
                ],
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey, size: 28),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _monthShort(DateTime date) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return months[date.month - 1];
  }
} 