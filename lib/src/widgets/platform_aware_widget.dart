import 'package:flutter/material.dart';
import '../constants/platform_colors.dart';
import '../utils/platform_utils.dart';

class PlatformAwareWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const PlatformAwareWidget({
    super.key,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: PlatformUtils.adaptiveElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PlatformUtils.adaptiveBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PlatformUtils.adaptiveBorderRadius),
        child: Container(
          padding: PlatformUtils.adaptivePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок с платформо-специфичным цветом
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: PlatformColors.textPrimary,
                  fontWeight: PlatformUtils.isIOS ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              
              // Индикатор платформы
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: PlatformColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  PlatformUtils.platformName,
                  style: TextStyle(
                    color: PlatformColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Финансовые индикаторы с платформо-специфичными цветами
              Row(
                children: [
                  _buildFinancialIndicator(
                    'Доход',
                    '+1,500 ₽',
                    PlatformColors.income,
                  ),
                  const SizedBox(width: 16),
                  _buildFinancialIndicator(
                    'Расход',
                    '-800 ₽',
                    PlatformColors.expense,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialIndicator(String label, String amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(PlatformUtils.adaptiveBorderRadius),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: PlatformColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: PlatformUtils.isIOS ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Виджет для демонстрации адаптивных кнопок
class AdaptiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const AdaptiveButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: PlatformColors.primary,
          foregroundColor: Colors.white,
          elevation: PlatformUtils.adaptiveElevation,
          padding: PlatformUtils.adaptivePadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PlatformUtils.adaptiveBorderRadius),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: PlatformUtils.isIOS ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      );
    } else {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: PlatformColors.primary,
          side: BorderSide(color: PlatformColors.primary),
          padding: PlatformUtils.adaptivePadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PlatformUtils.adaptiveBorderRadius),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: PlatformUtils.isIOS ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      );
    }
  }
}

// Виджет для демонстрации адаптивных полей ввода
class AdaptiveTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  const AdaptiveTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: PlatformColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PlatformUtils.adaptiveBorderRadius),
          borderSide: BorderSide(color: PlatformColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PlatformUtils.adaptiveBorderRadius),
          borderSide: BorderSide(color: PlatformColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PlatformUtils.adaptiveBorderRadius),
          borderSide: BorderSide(color: PlatformColors.primary, width: 2),
        ),
        contentPadding: PlatformUtils.adaptivePadding,
        labelStyle: TextStyle(
          color: PlatformColors.textSecondary,
          fontWeight: PlatformUtils.isIOS ? FontWeight.w500 : FontWeight.w400,
        ),
        hintStyle: TextStyle(
          color: PlatformColors.textSecondary,
          fontWeight: PlatformUtils.isIOS ? FontWeight.w400 : FontWeight.w300,
        ),
      ),
    );
  }
} 