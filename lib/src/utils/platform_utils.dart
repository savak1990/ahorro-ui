import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class PlatformUtils {
  // Определение платформы
  static bool get isWeb => kIsWeb;
  static bool get isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  static bool get isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => isWeb;
  
  // Дополнительные утилиты для адаптивной навигации
  static bool get shouldUseSideNavigation => isWeb;
  static bool get shouldUseBottomNavigation => isMobile;
  
  // Определение размера экрана для веб
  static bool get isWideScreen {
    if (!isWeb) return false;
    // Для веб проверяем ширину экрана через MediaQuery
    return true; // Будет определяться в виджете
  }

  // Методы для работы с платформо-специфичными стилями
  static double get adaptiveElevation {
    if (isIOS) return 0.0; // iOS не использует тени
    if (isAndroid) return 4.0; // Android использует Material Design тени
    return 2.0; // Web использует средние тени
  }

  static double get adaptiveBorderRadius {
    if (isIOS) return 8.0; // iOS использует более мягкие углы
    if (isAndroid) return 4.0; // Android использует Material Design углы
    return 6.0; // Web использует средние углы
  }

  static EdgeInsets get adaptivePadding {
    if (isIOS) return const EdgeInsets.all(16.0);
    if (isAndroid) return const EdgeInsets.all(12.0);
    return const EdgeInsets.all(14.0);
  }

  // Методы для определения системных настроек
  static bool get isDarkModeSupported {
    // iOS и Android поддерживают темную тему
    return isMobile;
  }

  static String get platformName {
    if (isIOS) return 'iOS';
    if (isAndroid) return 'Android';
    if (isWeb) return 'Web';
    return 'Unknown';
  }

  // Методы для адаптивных стилей
  static Map<String, dynamic> get adaptiveStyles {
    return {
      'elevation': adaptiveElevation,
      'borderRadius': adaptiveBorderRadius,
      'padding': adaptivePadding,
      'platform': platformName,
    };
  }
} 