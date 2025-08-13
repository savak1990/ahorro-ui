import 'package:flutter/material.dart';
import '../models/transaction_stats.dart';
import '../constants/app_strings.dart';
import './typography.dart';

class TransactionStatsCard extends StatelessWidget {
  final TransactionStatsResponse stats;
  final void Function(String currency, String type)? onTapCurrency;

  const TransactionStatsCard({
    super.key,
    required this.stats,
    this.onTapCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Expense section
        if (stats.expense != null && stats.expense!.currencies.isNotEmpty) ...[
          const TitleEmphasizedMedium(text: AppStrings.expenseTitle),
          const SizedBox(height: 8),
          _buildCurrencySection(
            context,
            stats.expense!,
            'expense',
          ),
          const SizedBox(height: 16),
        ],
        
        // Income section
        if (stats.income != null && stats.income!.currencies.isNotEmpty) ...[
          const TitleEmphasizedMedium(text: AppStrings.incomeTitle),
          const SizedBox(height: 8),
          _buildCurrencySection(
            context,
            stats.income!,
            'income',
          ),
        ],
      ],
    );
  }

  Widget _buildCurrencySection(
    BuildContext context,
    TransactionTypeStats typeStats,
    String type,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: typeStats.currencies.entries.toList().asMap().entries.map((mapEntry) {
          final index = mapEntry.key;
          final entry = mapEntry.value;
          final currency = entry.key;
          final currencyStats = entry.value;
          final isFirst = index == 0;
          final isLast = index == typeStats.currencies.length - 1;

          return _buildCurrencyItem(
            context,
            currency,
            currencyStats,
            type,
            isFirst,
            isLast,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCurrencyItem(
    BuildContext context,
    String currency,
    CurrencyStats currencyStats,
    String type,
    bool isFirst,
    bool isLast,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: isFirst ? const Radius.circular(16) : Radius.zero,
          topRight: isFirst ? const Radius.circular(16) : Radius.zero,
          bottomLeft: isLast ? const Radius.circular(16) : Radius.zero,
          bottomRight: isLast ? const Radius.circular(16) : Radius.zero,
        ),
      ),
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.only(
          topLeft: isFirst ? const Radius.circular(16) : Radius.zero,
          topRight: isFirst ? const Radius.circular(16) : Radius.zero,
          bottomLeft: isLast ? const Radius.circular(16) : Radius.zero,
          bottomRight: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        onTap: () => onTapCurrency?.call(currency, type),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Currency icon with background matching theme
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _getCurrencySymbol(currency),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Currency info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Amount on separate line
                        Text(
                          currencyStats.amountDecimal.toStringAsFixed(2),
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${currencyStats.transactionsCount} transactions',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Arrow indicator
                  const SizedBox(width: 8),
                  if (onTapCurrency != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      color: colorScheme.onSurfaceVariant,
                      size: 16,
                    ),
                ],
              ),
            ),
            // Divider between items (except last)
            if (!isLast)
              const Divider(
                height: 1,
                thickness: 1,
                indent: 76, // 16 + 44 + 16 (отступ + иконка + отступ)
                endIndent: 16,
              ),
          ],
        ),
      ),
    );
  }

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'RUB':
        return '₽';
      default:
        return currency;
    }
  }
}
