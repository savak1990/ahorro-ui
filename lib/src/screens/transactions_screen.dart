import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

    final title = type == 'income' ? 'Income' : 'Expense';
    final monthStr = DateFormat('MMMM, yyyy').format(month);

    return Scaffold(
      appBar: AppBar(
        title: Text('$title · $monthStr'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => const SizedBox(
                  height: 200,
                  child: Center(child: Text('Filter menu (mock)')),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.segment),
            tooltip: 'Group',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => const SizedBox(
                  height: 200,
                  child: Center(child: Text('Grouping menu (mock)')),
                ),
              );
            },
          ),
        ],
      ),
      body: filtered.isEmpty
          ? const Center(child: Text('No transactions'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final tx = filtered[i];
                final txDate = tx['date'] as DateTime;
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
                            DateFormat('d').format(txDate),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            DateFormat('MMM').format(txDate).toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Иконка категории
                      Icon(
                        tx['categoryIcon'] as IconData,
                        size: 32,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 16),
                      // Категория и счет
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx['category'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              tx['account'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Сумма
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            tx['amount'].toStringAsFixed(0),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: tx['type'] == 'expense' ? Colors.red : Colors.green,
                            ),
                          ),
                          Text(
                            'EUR',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: tx['type'] == 'expense' ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
} 