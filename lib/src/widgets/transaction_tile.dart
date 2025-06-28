import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

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
    final isExpense = type == 'expense';
    final isIncome = type == 'income';
    
    // Определяем иконку типа транзакции
    IconData typeIcon;
    Color typeColor;
    
    if (isIncome) {
      typeIcon = Icons.trending_up;
      typeColor = AppColors.primary; // Используем primary цвет проекта
    } else if (isExpense) {
      typeIcon = Icons.trending_down;
      typeColor = AppColors.error; // Используем error цвет проекта
    } else {
      typeIcon = Icons.swap_horiz;
      typeColor = AppColors.accent; // Используем accent цвет проекта
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  typeIcon,
                  color: typeColor,
                  size: 20,
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Вторая строка: категория
                    Text(
                      category,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Третья строка: баланс и валюта
                    Text(
                      '$account • $currency',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
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
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isExpense 
                          ? AppColors.error 
                          : isIncome 
                              ? AppColors.primary 
                              : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currency,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              // Стрелка справа (если есть onTap)
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 