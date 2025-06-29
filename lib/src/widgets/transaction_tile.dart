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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isExpense = type == 'expense';
    final isIncome = type == 'income';
    
    // Определяем иконку типа транзакции
    IconData typeIcon;
    Color typeColor;
    
    if (isIncome) {
      typeIcon = Icons.trending_up;
      typeColor = colorScheme.primary;
    } else if (isExpense) {
      typeIcon = Icons.trending_down;
      typeColor = colorScheme.error;
    } else {
      typeIcon = Icons.swap_horiz;
      typeColor = colorScheme.secondary;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(0),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Иконка типа транзакции
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  typeIcon,
                  color: typeColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              
              // Основная информация
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Первая строка: мерчант (description или category)
                    Text(
                      description?.isNotEmpty == true ? description! : category,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Вторая строка: категория
                    Text(
                      category,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Третья строка: баланс и валюта
                    Text(
                      '$account • $currency',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Сумма справа
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isExpense ? '-' : isIncome ? '+' : ''}${amount.toStringAsFixed(2)}',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isExpense 
                          ? colorScheme.error 
                          : isIncome 
                              ? colorScheme.primary 
                              : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currency,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              // Стрелка справа (если есть onTap)
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  color: colorScheme.onSurfaceVariant,
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 