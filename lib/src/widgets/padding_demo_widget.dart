import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/platform_colors.dart';

/// Демонстрационный виджет для проверки единообразия отступов
class PaddingDemoWidget extends StatelessWidget {
  const PaddingDemoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.horizontalPadding, 
            24, 
            AppConstants.horizontalPadding, 
            16
          ),
          child: Text(
            'Padding Demo',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 32,
            ),
          ),
        ),
        
        // Карточка с отступами как MonthlyOverviewCard
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.horizontalPadding,
            vertical: 8,
          ),
          child: Card(
            elevation: 4.0,
            color: PlatformColors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius)
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MonthlyOverviewCard equivalent',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Horizontal padding: ${AppConstants.horizontalPadding}px',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Card border radius: ${AppConstants.cardBorderRadius}px',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Список элементов как в TransactionsScreen
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.horizontalPadding,
            vertical: 8,
          ),
          child: Column(
            children: [
              // Заголовок группы
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8, left: 0, right: 0),
                child: Text(
                  'Transactions equivalent',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              // Элемент списка
              Card(
                elevation: 2.0,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: PlatformColors.primary,
                    child: Icon(Icons.receipt, color: PlatformColors.surface),
                  ),
                  title: Text('Transaction Item'),
                  subtitle: Text('Horizontal padding: ${AppConstants.horizontalPadding}px'),
                  trailing: Text('€100.00'),
                ),
              ),
            ],
          ),
        ),
        
        // Информация об отступах
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.horizontalPadding,
            vertical: 16,
          ),
          child: Card(
            color: PlatformColors.primary.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Padding Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('• Horizontal padding: ${AppConstants.horizontalPadding}px'),
                  Text('• Screen padding: ${AppConstants.screenPadding}px'),
                  Text('• Card border radius: ${AppConstants.cardBorderRadius}px'),
                  Text('• Both screens now use identical horizontal spacing'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
} 