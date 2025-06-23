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
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = type == 'expense';
    final isIncome = type == 'income';
    final amountColor = isExpense ? Colors.red : Colors.green;
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Дата
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                date.day.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                _monthShort(date),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Иконка категории
          Icon(categoryIcon, size: 32, color: Colors.black),
          const SizedBox(width: 16),
          // Категория и счет
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
                  ),
              ],
            ),
          ),
          // Сумма
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount.toStringAsFixed(0),
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
        ],
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