import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../constants/platform_colors.dart';
import '../constants/app_typography.dart';
import '../utils/platform_utils.dart';

class AdaptiveTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Адаптивная цветовая схема
      colorScheme: ColorScheme.light(
        primary: PlatformColors.primary,
        primaryContainer: PlatformColors.primary.withValues(alpha: 0.1),
        secondary: PlatformColors.secondary,
        surface: PlatformColors.surface,
        error: PlatformColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: PlatformColors.textPrimary,
        onError: Colors.white,
      ),

      // Типографика (одинаковая для всех платформ)
      textTheme: const TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        titleSmall: AppTypography.titleSmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),

      // Адаптивная App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: PlatformColors.surface,
        foregroundColor: PlatformColors.textPrimary,
        elevation: PlatformUtils.adaptiveElevation,
        centerTitle: PlatformUtils.isIOS, // iOS центрирует заголовки
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: PlatformColors.textPrimary,
        ),
        systemOverlayStyle: PlatformUtils.isIOS 
          ? SystemUiOverlayStyle.dark 
          : SystemUiOverlayStyle.light,
      ),

      // Адаптивные карточки
      cardTheme: CardThemeData(
        color: PlatformColors.cardBackground,
        elevation: PlatformUtils.adaptiveElevation,
        shadowColor: PlatformColors.cardShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformUtils.adaptiveBorderRadius),
        ),
        margin: PlatformUtils.adaptivePadding,
      ),

      // Адаптивные кнопки
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PlatformColors.primary,
          foregroundColor: Colors.white,
          elevation: PlatformUtils.adaptiveElevation,
          padding: PlatformUtils.adaptivePadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PlatformUtils.adaptiveBorderRadius),
          ),
          textStyle: AppTypography.labelLarge.copyWith(
            color: Colors.white,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PlatformColors.primary,
          side: BorderSide(color: PlatformColors.primary),
          padding: PlatformUtils.adaptivePadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PlatformUtils.adaptiveBorderRadius),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: PlatformColors.primary,
          padding: PlatformUtils.adaptivePadding,
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // Адаптивные поля ввода
      inputDecorationTheme: InputDecorationTheme(
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PlatformUtils.adaptiveBorderRadius),
          borderSide: BorderSide(color: PlatformColors.error),
        ),
        contentPadding: PlatformUtils.adaptivePadding,
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: PlatformColors.textSecondary,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: PlatformColors.textSecondary,
        ),
      ),

      // Адаптивная нижняя навигация
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: PlatformColors.surface,
        selectedItemColor: PlatformColors.primary,
        unselectedItemColor: PlatformColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: PlatformUtils.adaptiveElevation,
      ),

      // Адаптивная плавающая кнопка
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: PlatformColors.primary,
        foregroundColor: Colors.white,
        elevation: PlatformUtils.adaptiveElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformUtils.isIOS ? 16.0 : 8.0),
        ),
      ),

      // Адаптивные разделители
      dividerTheme: DividerThemeData(
        color: PlatformColors.divider,
        thickness: 1,
        space: 1,
      ),

      // Фон
      scaffoldBackgroundColor: PlatformColors.background,

      // Адаптивная плотность
      visualDensity: PlatformUtils.isIOS 
        ? VisualDensity.standard 
        : VisualDensity.comfortable,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Адаптивная темная цветовая схема
      colorScheme: ColorScheme.dark(
        primary: PlatformColors.darkPrimary,
        primaryContainer: PlatformColors.darkPrimary.withValues(alpha: 0.1),
        secondary: PlatformColors.secondary,
        surface: PlatformColors.darkSurface,
        error: PlatformColors.error,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: PlatformColors.darkTextPrimary,
        onError: Colors.white,
      ),

      // Типографика (та же, что и в светлой теме)
      textTheme: const TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        titleSmall: AppTypography.titleSmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),

      // Адаптивная темная App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: PlatformColors.darkSurface,
        foregroundColor: PlatformColors.darkTextPrimary,
        elevation: PlatformUtils.adaptiveElevation,
        centerTitle: PlatformUtils.isIOS,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: PlatformColors.darkTextPrimary,
        ),
        systemOverlayStyle: PlatformUtils.isIOS 
          ? SystemUiOverlayStyle.light 
          : SystemUiOverlayStyle.dark,
      ),

      // Адаптивные темные карточки
      cardTheme: CardThemeData(
        color: PlatformColors.darkSurface,
        elevation: PlatformUtils.adaptiveElevation,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformUtils.adaptiveBorderRadius),
        ),
        margin: PlatformUtils.adaptivePadding,
      ),

      // Адаптивные темные кнопки
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PlatformColors.darkPrimary,
          foregroundColor: Colors.black,
          elevation: PlatformUtils.adaptiveElevation,
          padding: PlatformUtils.adaptivePadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PlatformUtils.adaptiveBorderRadius),
          ),
          textStyle: AppTypography.labelLarge.copyWith(
            color: Colors.black,
          ),
        ),
      ),

      // Адаптивные темные поля ввода
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PlatformColors.darkSurface,
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
          borderSide: BorderSide(color: PlatformColors.darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PlatformUtils.adaptiveBorderRadius),
          borderSide: BorderSide(color: PlatformColors.error),
        ),
        contentPadding: PlatformUtils.adaptivePadding,
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: PlatformColors.darkTextSecondary,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: PlatformColors.darkTextSecondary,
        ),
      ),

      // Адаптивная темная нижняя навигация
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: PlatformColors.darkSurface,
        selectedItemColor: PlatformColors.darkPrimary,
        unselectedItemColor: PlatformColors.darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: PlatformUtils.adaptiveElevation,
      ),

      // Адаптивная темная плавающая кнопка
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: PlatformColors.darkPrimary,
        foregroundColor: Colors.black,
        elevation: PlatformUtils.adaptiveElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformUtils.isIOS ? 16.0 : 8.0),
        ),
      ),

      // Фон
      scaffoldBackgroundColor: PlatformColors.darkBackground,

      // Адаптивная плотность
      visualDensity: PlatformUtils.isIOS 
        ? VisualDensity.standard 
        : VisualDensity.comfortable,
    );
  }

  // Метод для получения текущей темы
  static ThemeData getCurrentTheme({bool isDark = false}) {
    return isDark ? darkTheme : lightTheme;
  }

  // Метод для получения платформо-специфичных стилей
  static Map<String, dynamic> getPlatformSpecificStyles() {
    return {
      'elevation': PlatformUtils.adaptiveElevation,
      'borderRadius': PlatformUtils.adaptiveBorderRadius,
      'padding': PlatformUtils.adaptivePadding,
      'platform': PlatformUtils.platformName,
      'primaryColor': PlatformColors.primary,
      'backgroundColor': PlatformColors.background,
    };
  }
} 