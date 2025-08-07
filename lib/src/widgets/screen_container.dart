import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Переиспользуемый контейнер для экранов с единообразными отступами
class ScreenContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool useDefaultPadding;
  final Color? backgroundColor;

  const ScreenContainer({
    super.key,
    required this.child,
    this.padding,
    this.useDefaultPadding = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPadding = EdgeInsets.all(AppConstants.screenPadding);
    final finalPadding = useDefaultPadding 
        ? (padding ?? defaultPadding)
        : padding;

    return Container(
      color: backgroundColor,
      padding: finalPadding,
      child: child,
    );
  }
}

/// Переиспользуемый контейнер для списков с единообразными отступами
class ListContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool useDefaultPadding;

  const ListContainer({
    super.key,
    required this.child,
    this.padding,
    this.useDefaultPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPadding = EdgeInsets.symmetric(
      horizontal: AppConstants.screenPadding,
      vertical: 4,
    );
    final finalPadding = useDefaultPadding 
        ? (padding ?? defaultPadding)
        : (padding ?? EdgeInsets.zero);

    return Padding(
      padding: finalPadding,
      child: child,
    );
  }
} 