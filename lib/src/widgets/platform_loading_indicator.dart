import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

class PlatformLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double? size;
  final EdgeInsetsGeometry? padding;

  const PlatformLoadingIndicator({
    super.key,
    this.color,
    this.size,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultColor = color ?? theme.colorScheme.primary;
    final defaultSize = size ?? _getPlatformSpecificSize();
    final defaultPadding = padding ?? _getPlatformSpecificPadding();

    return Padding(
      padding: defaultPadding,
      child: _buildPlatformSpecificIndicator(defaultColor, defaultSize),
    );
  }

  Widget _buildPlatformSpecificIndicator(Color color, double size) {
    if (Platform.isIOS) {
      // iOS - CupertinoActivityIndicator
      return CupertinoActivityIndicator(
        color: color,
        radius: size / 2,
      );
    } else if (Platform.isAndroid) {
      // Android - CircularProgressIndicator
      return SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          color: color,
          strokeWidth: 3.0,
        ),
      );
    } else {
      // Web - CircularProgressIndicator с CSS анимациями
      return SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          color: color,
          strokeWidth: 3.0,
        ),
      );
    }
  }

  double _getPlatformSpecificSize() {
    if (Platform.isIOS) {
      return 20.0; // iOS размер
    } else if (Platform.isAndroid) {
      return 24.0; // Android размер
    } else {
      return 24.0; // Web размер
    }
  }

  EdgeInsetsGeometry _getPlatformSpecificPadding() {
    if (Platform.isIOS) {
      return const EdgeInsets.all(20.0); // iOS отступы
    } else if (Platform.isAndroid) {
      return const EdgeInsets.all(16.0); // Android отступы
    } else {
      return const EdgeInsets.all(16.0); // Web отступы
    }
  }
} 