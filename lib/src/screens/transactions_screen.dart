import 'package:flutter/material.dart';
import '../widgets/transaction_tile.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final String type = args?['type'] ?? 'expense';
    final DateTime month = args?['month'] ?? DateTime.now();

    // Mock data
    final List<Map<String, dynamic>> allTransactions = [
      {
        'id': '1',
        'type': 'expense',
        'amount': 350.0,
        'category': 'Many categories',
        'categoryIcon': Icons.blur_circular,
        'account': 'Sergey BBVA main',
        'description': '',
        'date': DateTime(month.year, month.month, 15),
      },
      {
        'id': '2',
        'type': 'income',
        'amount': 200.0,
        'category': 'Salary',
        'categoryIcon': Icons.attach_money,
        'account': 'Sergey BBVA main',
        'description': 'June salary',
        'date': DateTime(month.year, month.month, 10),
      },
      {
        'id': '3',
        'type': 'expense',
        'amount': 20.0,
        'category': 'Cafe',
        'categoryIcon': Icons.local_cafe,
        'account': 'Sergey BBVA main',
        'description': 'Coffee',
        'date': DateTime(month.year, month.month, 5),
      },
      {
        'id': '4',
        'type': 'income',
        'amount': 50.0,
        'category': 'Gift',
        'categoryIcon': Icons.card_giftcard,
        'account': 'Sergey BBVA main',
        'description': 'Birthday gift',
        'date': DateTime(month.year, month.month, 2),
      },
      {
        'id': '5',
        'type': 'expense',
        'amount': 100.0,
        'category': 'Transport',
        'categoryIcon': Icons.directions_car,
        'account': 'Sergey BBVA main',
        'description': 'Taxi',
        'date': DateTime(month.year, month.month, 1),
      },
    ];

    // Фильтрация по типу и месяцу
    final filtered = allTransactions.where((tx) {
      final txDate = tx['date'] as DateTime;
      return tx['type'] == type &&
        txDate.year == month.year &&
        txDate.month == month.month;
    }).toList();

    // Пример использования TransactionTile:
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transactions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final tx = filtered[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TransactionTile(
                    type: tx['type'],
                    amount: tx['amount'],
                    category: tx['category'],
                    categoryIcon: tx['categoryIcon'],
                    account: tx['account'],
                    date: tx['date'],
                    description: tx['description'],
                    currency: 'EUR',
                    onTap: () {}, // TODO: переход к деталям
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: переход на экран добавления транзакции
        },
        child: const Icon(Icons.add, size: 32),
        shape: const CircleBorder(),
        // Можно добавить backgroundColor: AppColors.primary, если есть
        // backgroundColor: Colors.black,
        // увеличенный minSize через Theme
      ),
    );
  }
} 