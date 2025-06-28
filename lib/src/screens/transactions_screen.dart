import 'package:flutter/material.dart';
import '../widgets/transaction_tile.dart';
import '../services/api_service.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late Future<List<TransactionDisplayData>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _fetchTransactions();
  }

  Future<List<TransactionDisplayData>> _fetchTransactions() async {
    try {
      final response = await ApiService.getTransactions();
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      final DateTime filterMonth = args?['month'] ?? DateTime.now();

      debugPrint('Fetched ${response.transactionEntries.length} transaction entries');
      debugPrint('Filtering by month: ${filterMonth.year}-${filterMonth.month}');

      // Группируем транзакции по уникальным атрибутам
      final Map<String, List<TransactionEntryData>> groupedTransactions = {};
      
      for (final entry in response.transactionEntries) {
        final key = '${entry.transactionId}_${entry.type}_${entry.balanceTitle}_${entry.balanceCurrency}_${entry.approvedAt.toIso8601String()}_${entry.merchantName}';
        
        if (!groupedTransactions.containsKey(key)) {
          groupedTransactions[key] = [];
        }
        groupedTransactions[key]!.add(entry);
      }

      debugPrint('Grouped into ${groupedTransactions.length} unique transactions');

      // Преобразуем сгруппированные данные в отображаемые транзакции
      final List<TransactionDisplayData> displayTransactions = [];
      
      for (final group in groupedTransactions.values) {
        if (group.isEmpty) continue;
        
        final firstEntry = group.first;
        
        // Проверяем фильтр только по месяцу (убираем фильтр по типу)
        final entryDate = firstEntry.transactedAt;
        if (entryDate.year != filterMonth.year || entryDate.month != filterMonth.month) {
          debugPrint('Skipping transaction from different month: ${entryDate.year}-${entryDate.month}');
          continue;
        }

        // Обрабатываем категории
        final categories = group.map((e) => e.categoryName).toSet();
        final categoryName = categories.length > 1 ? 'Multiple Categories' : categories.first;

        // Суммируем amounts
        final totalAmount = group.fold(0.0, (sum, entry) => sum + entry.amount);

        // Определяем иконку категории
        IconData categoryIcon = _getCategoryIcon(categoryName);

        debugPrint('Adding transaction: type=${firstEntry.type}, amount=$totalAmount, category=$categoryName, date=${entryDate.day}');

        displayTransactions.add(TransactionDisplayData(
          id: firstEntry.transactionId,
          type: firstEntry.type,
          amount: totalAmount,
          category: categoryName,
          categoryIcon: categoryIcon,
          account: firstEntry.balanceTitle,
          description: firstEntry.merchantName,
          date: firstEntry.transactedAt,
          currency: firstEntry.balanceCurrency,
        ));
      }

      // Сортируем по дате (новые сначала)
      displayTransactions.sort((a, b) => b.date.compareTo(a.date));

      debugPrint('Final display transactions: ${displayTransactions.length}');
      return displayTransactions;
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      return [];
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'groceries':
      case 'food':
        return Icons.shopping_cart;
      case 'transport':
      case 'taxi':
        return Icons.directions_car;
      case 'cafe':
      case 'restaurant':
        return Icons.local_cafe;
      case 'salary':
      case 'income':
        return Icons.attach_money;
      case 'gift':
        return Icons.card_giftcard;
      case 'multiple categories':
        return Icons.blur_circular;
      default:
        return Icons.category;
    }
  }

  void _refreshTransactions() {
    setState(() {
      _transactionsFuture = _fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final DateTime month = args?['month'] ?? DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Transactions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTransactions,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<TransactionDisplayData>>(
              future: _transactionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading transactions',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _refreshTransactions,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final transactions = snapshot.data ?? [];

                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'for ${_getMonthName(month)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: transactions.length,
                  itemBuilder: (context, i) {
                    final tx = transactions[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TransactionTile(
                        type: tx.type,
                        amount: tx.amount,
                        category: tx.category,
                        categoryIcon: tx.categoryIcon,
                        account: tx.account,
                        date: tx.date,
                        description: tx.description,
                        currency: tx.currency,
                        onTap: () {}, // TODO: переход к деталям
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) => const AddTransactionScreen(),
          ).then((_) {
            // Обновляем транзакции после добавления новой
            _refreshTransactions();
          });
        },
        child: const Icon(Icons.add, size: 32),
        shape: const CircleBorder(),
      ),
    );
  }

  String _getMonthName(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[date.month - 1];
  }
}

class TransactionDisplayData {
  final String id;
  final String type;
  final double amount;
  final String category;
  final IconData categoryIcon;
  final String account;
  final String? description;
  final DateTime date;
  final String currency;

  TransactionDisplayData({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.categoryIcon,
    required this.account,
    this.description,
    required this.date,
    required this.currency,
  });
} 