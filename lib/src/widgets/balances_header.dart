import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

class BalancesHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const BalancesHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Платформо-специфичные стили
    final defaultTitleStyle = _getPlatformSpecificTitleStyle(textTheme, colorScheme);
    final defaultSubtitleStyle = _getPlatformSpecificSubtitleStyle(textTheme, colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: titleStyle ?? defaultTitleStyle,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: subtitleStyle ?? defaultSubtitleStyle,
        ),
      ],
    );
  }

  TextStyle _getPlatformSpecificTitleStyle(TextTheme textTheme, ColorScheme colorScheme) {
    if (Platform.isIOS) {
      // iOS стили - более крупные шрифты, SF Pro Display
      return textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        letterSpacing: -0.5,
        fontSize: 32, // iOS обычно использует более крупные шрифты
      ) ?? const TextStyle();
    } else if (Platform.isAndroid) {
      // Android стили - Material Design
      return textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        letterSpacing: -0.5,
      ) ?? const TextStyle();
    } else {
      // Web стили - responsive
      return textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        letterSpacing: -0.5,
      ) ?? const TextStyle();
    }
  }

  TextStyle _getPlatformSpecificSubtitleStyle(TextTheme textTheme, ColorScheme colorScheme) {
    if (Platform.isIOS) {
      // iOS стили
      return textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
        letterSpacing: 0.15,
        fontSize: 18, // iOS размер
      ) ?? const TextStyle();
    } else if (Platform.isAndroid) {
      // Android стили
      return textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
        letterSpacing: 0.15,
      ) ?? const TextStyle();
    } else {
      // Web стили
      return textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
        letterSpacing: 0.15,
      ) ?? const TextStyle();
    }
  }
} 