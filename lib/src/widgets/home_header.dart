import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

class HomeHeader extends StatelessWidget {
  final String userName;
  final String dateText;
  final TextStyle? userNameStyle;
  final TextStyle? dateStyle;

  const HomeHeader({
    super.key,
    required this.userName,
    required this.dateText,
    this.userNameStyle,
    this.dateStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Платформо-специфичные стили
    final defaultUserNameStyle = _getPlatformSpecificUserNameStyle(textTheme, colorScheme);
    final defaultDateStyle = _getPlatformSpecificDateStyle(textTheme, colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, $userName!',
          style: userNameStyle ?? defaultUserNameStyle,
        ),
        const SizedBox(height: 8),
        Text(
          dateText,
          style: dateStyle ?? defaultDateStyle,
        ),
      ],
    );
  }

  TextStyle _getPlatformSpecificUserNameStyle(TextTheme textTheme, ColorScheme colorScheme) {
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

  TextStyle _getPlatformSpecificDateStyle(TextTheme textTheme, ColorScheme colorScheme) {
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