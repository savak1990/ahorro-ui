import 'package:flutter/foundation.dart';

class PlatformUtils {
  static bool get isWeb => kIsWeb;
  static bool get isAndroid => !kIsWeb; // Упрощенная логика для мобильных
  static bool get isIOS => !kIsWeb;     // Упрощенная логика для мобильных
  static bool get isMobile => !kIsWeb;
  static bool get isDesktop => kIsWeb;
  
  // Дополнительные утилиты для адаптивной навигации
  static bool get shouldUseSideNavigation => isWeb;
  static bool get shouldUseBottomNavigation => isMobile;
  
  // Определение размера экрана для веб
  static bool get isWideScreen {
    if (!isWeb) return false;
    // Для веб проверяем ширину экрана через MediaQuery
    return true; // Будет определяться в виджете
  }
} 