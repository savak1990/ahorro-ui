import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
import '../widgets/transaction_tile.dart';
import '../constants/app_typography.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final String transactionId;
  const TransactionDetailsScreen({Key? key, required this.transactionId}) : super(key: key);

  @override
  State<TransactionDetailsScreen> createState() => _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  Map<String, dynamic>? transactionData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchTransactionDetails();
  }

  Future<void> fetchTransactionDetails() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final data = await ApiService.getTransactionById(widget.transactionId);
      setState(() {
        transactionData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Ошибка: $e';
        isLoading = false;
      });
    }
  }

  Color _typeColor(String type, ThemeData theme) {
    switch (type.toLowerCase()) {
      case 'income':
        return Colors.green;
      case 'expense':
        return theme.colorScheme.error;
      case 'movement':
        return Colors.blue;
      default:
        return theme.colorScheme.primary;
    }
  }

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'income':
        return Icons.trending_up;
      case 'expense':
        return Icons.trending_down;
      case 'movement':
        return Icons.swap_horiz;
      default:
        return Icons.category;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : transactionData == null
                  ? const Center(child: Text('Нет данных'))
                  : _buildDetails(context, theme, textTheme),
    );
  }

  Widget _buildDetails(BuildContext context, ThemeData theme, TextTheme textTheme) {
    final tx = transactionData!;
    final type = tx['Type'] ?? '-';
    final entries = (tx['TransactionEntries'] as List?) ?? [];
    double totalAmount = 0.0;
    for (final entry in entries) {
      final amt = (entry as Map<String, dynamic>)['Amount'];
      if (amt != null) {
        totalAmount += (double.tryParse(amt.toString()) ?? 0.0) / 100;
      }
    }
    final mainEntry = entries.isNotEmpty ? entries[0] as Map<String, dynamic> : null;
    final category = mainEntry != null && mainEntry['Category'] != null ? mainEntry['Category']['CategoryName'] : '-';
    final description = mainEntry != null ? mainEntry['Description'] : null;
    final date = tx['TransactedAt'] ?? tx['ApprovedAt'] ?? tx['CreatedAt'];
    final balance = tx['Balance']?['Title'] ?? '-';
    final merchant = tx['Merchant'] ?? '-';
    final currency = tx['Balance']?['Currency'] ?? 'EUR';
    final parsedDate = date != null ? DateTime.tryParse(date) : null;
    final formattedDate = parsedDate != null ? DateFormat('dd.MM.yyyy HH:mm').format(parsedDate) : '-';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Тип и сумма
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _typeColor(type, theme).withOpacity(0.1),
                  child: Icon(_typeIcon(type), color: _typeColor(type, theme)),
                ),
                const SizedBox(width: 16),
                Text(
                  type[0].toUpperCase() + type.substring(1),
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                ),
                const Spacer(),
                Text(
                  (type == 'expense' ? '-' : type == 'income' ? '+' : '') + totalAmount.toStringAsFixed(2) + ' $currency',
                  style: AppTypography.headlineSmall.copyWith(
                    color: _typeColor(type, theme),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Категория
            Row(
              children: [
                Icon(Icons.category, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(category, style: AppTypography.titleMedium.copyWith(color: theme.colorScheme.onSurface)),
              ],
            ),
            const SizedBox(height: 16),
            // Дата
            Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(formattedDate, style: AppTypography.bodyLarge.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 16),
            // Описание
            if (description != null && description.toString().isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.description, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(description.toString(), style: AppTypography.bodyLarge.copyWith(color: theme.colorScheme.onSurfaceVariant))),
                ],
              ),
              const SizedBox(height: 16),
            ],
            // Счет
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(balance, style: AppTypography.bodyLarge.copyWith(color: theme.colorScheme.onSurface)),
              ],
            ),
            const SizedBox(height: 16),
            // Мерчант
            if (merchant != null && merchant.toString().isNotEmpty && merchant != '-') ...[
              Row(
                children: [
                  Icon(Icons.store, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(merchant.toString(), style: AppTypography.bodyLarge.copyWith(color: theme.colorScheme.onSurface))),
                ],
              ),
              const SizedBox(height: 16),
            ],
            // Entries (если их несколько)
            if (entries.length > 1) ...[
              const Divider(),
              Text('Entries', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (int i = 0; i < entries.length; i++) ...[
                      if (i > 0) const Divider(height: 1, thickness: 1),
                      Builder(builder: (context) {
                        final e = entries[i] as Map<String, dynamic>;
                        final cat = e['Category']?['CategoryName'] ?? '-';
                        final amt = e['Amount'] != null ? (double.tryParse(e['Amount'].toString()) ?? 0.0) / 100 : 0.0;
                        final desc = e['Description'] ?? '';
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: i == 0 && entries.length == 1
                                ? BorderRadius.circular(16)
                                : i == 0
                                    ? const BorderRadius.vertical(top: Radius.circular(16))
                                    : i == entries.length - 1
                                        ? const BorderRadius.vertical(bottom: Radius.circular(16))
                                        : BorderRadius.zero,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(_getCategoryIcon(cat), color: theme.colorScheme.primary, size: 22),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cat,
                                      style: AppTypography.titleMedium.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (desc.toString().isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        desc,
                                        style: AppTypography.bodyMedium.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                amt.toStringAsFixed(2),
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 