import 'package:flutter/material.dart';
import '../constants/platform_colors.dart';
import '../utils/platform_utils.dart';

class FinancialPaletteDemo extends StatelessWidget {
  const FinancialPaletteDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: PlatformUtils.adaptiveElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PlatformUtils.adaptiveBorderRadius),
      ),
      child: Padding(
        padding: PlatformUtils.adaptivePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Text(
              'Финансовая палитра',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: PlatformColors.textPrimary,
                fontWeight: PlatformUtils.isIOS ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Основные цвета
            _buildColorSection('Основные цвета', [
              _ColorItem('Primary', PlatformColors.primary, 'Основной'),
              _ColorItem('Secondary', PlatformColors.secondary, 'Вторичный'),
              _ColorItem('Success', PlatformColors.success, 'Успех'),
              _ColorItem('Warning', PlatformColors.warning, 'Предупреждение'),
              _ColorItem('Error', PlatformColors.error, 'Ошибка'),
            ]),
            
            const SizedBox(height: 20),
            
            // Финансовые цвета
            _buildColorSection('Финансовые цвета', [
              _ColorItem('Доход', PlatformColors.income, 'Прибыль'),
              _ColorItem('Расход', PlatformColors.expense, 'Убыток'),
              _ColorItem('Баланс', PlatformColors.balance, 'Общий баланс'),
              _ColorItem('Инвестиции', PlatformColors.investment, 'Портфель'),
              _ColorItem('Сбережения', PlatformColors.savings, 'Накопления'),
              _ColorItem('Долг', PlatformColors.debt, 'Кредиты'),
              _ColorItem('Бюджет', PlatformColors.budget, 'Планирование'),
            ]),
            
            const SizedBox(height: 20),
            
            // Примеры использования
            Text(
              'Примеры использования',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: PlatformColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Финансовые карточки
            _buildFinancialCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSection(String title, List<_ColorItem> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: PlatformColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...colors.map((color) => _buildColorRow(color)),
      ],
    );
  }

  Widget _buildColorRow(_ColorItem colorItem) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: colorItem.color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: PlatformColors.border,
                width: 1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              colorItem.name,
              style: TextStyle(
                color: PlatformColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            colorItem.description,
            style: TextStyle(
              color: PlatformColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '#${colorItem.color.value.toRadixString(16).substring(2).toUpperCase()}',
            style: TextStyle(
              color: PlatformColors.textSecondary,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCards() {
    return Column(
      children: [
        // Доходы и расходы
        Row(
          children: [
            Expanded(
              child: _buildFinancialCard(
                'Доходы',
                '+15,420 ₽',
                PlatformColors.income,
                Icons.trending_up,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFinancialCard(
                'Расходы',
                '-8,750 ₽',
                PlatformColors.expense,
                Icons.trending_down,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Баланс и сбережения
        Row(
          children: [
            Expanded(
              child: _buildFinancialCard(
                'Баланс',
                '6,670 ₽',
                PlatformColors.balance,
                Icons.account_balance_wallet,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFinancialCard(
                'Сбережения',
                '45,200 ₽',
                PlatformColors.savings,
                Icons.savings,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Инвестиции и бюджет
        Row(
          children: [
            Expanded(
              child: _buildFinancialCard(
                'Инвестиции',
                '125,800 ₽',
                PlatformColors.investment,
                Icons.show_chart,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFinancialCard(
                'Бюджет',
                '12,000 ₽',
                PlatformColors.budget,
                Icons.pie_chart,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialCard(String title, String amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(PlatformUtils.adaptiveBorderRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: PlatformColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: PlatformUtils.isIOS ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorItem {
  final String name;
  final Color color;
  final String description;

  _ColorItem(this.name, this.color, this.description);
} 