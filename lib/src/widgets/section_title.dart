import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../utils/platform_utils.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final TextStyle? style;
  final EdgeInsetsGeometry? padding;

  const SectionTitle({
    super.key,
    required this.title,
    this.style,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final defaultStyle = _getPlatformSpecificStyle(textTheme, colorScheme);
    final defaultPadding = _getPlatformSpecificPadding();

    return Padding(
      padding: padding ?? defaultPadding,
      child: Text(
        title,
        style: style ?? defaultStyle,
      ),
    );
  }

  TextStyle _getPlatformSpecificStyle(TextTheme textTheme, ColorScheme colorScheme) {
    if (PlatformUtils.isIOS) {
      // iOS стили - SF Pro Display, более крупные размеры
      return textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        letterSpacing: 0.15,
        fontSize: 24, // iOS размер
      ) ?? const TextStyle();
    } else if (PlatformUtils.isAndroid) {
      // Android стили - Material Design
      return textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        letterSpacing: 0.15,
      ) ?? const TextStyle();
    } else {
      // Web стили - responsive
      return textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        letterSpacing: 0.15,
      ) ?? const TextStyle();
    }
  }

  EdgeInsetsGeometry _getPlatformSpecificPadding() {
    if (PlatformUtils.isIOS) {
      // iOS отступы - обычно больше
      return const EdgeInsets.only(top: 32, bottom: 16);
    } else if (PlatformUtils.isAndroid) {
      // Android отступы - Material Design
      return const EdgeInsets.only(top: 32, bottom: 16);
    } else {
      // Web отступы - responsive
      return const EdgeInsets.only(top: 32, bottom: 16);
    }
  }
} 