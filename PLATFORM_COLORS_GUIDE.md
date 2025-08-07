# Руководство по управлению цветами для Android и iOS

## Обзор

Этот проект использует адаптивную систему цветов, которая автоматически применяет соответствующие цвета для каждой платформы (Android, iOS, Web) в соответствии с их дизайн-системами.

## Структура файлов

```
lib/src/
├── constants/
│   ├── app_colors.dart          # Универсальные цвета (устаревшие)
│   └── platform_colors.dart     # Платформо-специфичные цвета (новые)
├── config/
│   ├── app_theme.dart           # Универсальные темы (устаревшие)
│   └── adaptive_theme.dart      # Адаптивные темы (новые)
├── utils/
│   └── platform_utils.dart      # Утилиты для определения платформы
└── widgets/
    └── platform_aware_widget.dart # Примеры использования
```

## Основные принципы

### 1. Платформо-специфичные цвета

- **iOS**: Следует Human Interface Guidelines (HIG)
- **Android**: Следует Material Design Guidelines
- **Web**: Использует адаптивную схему

### 2. Автоматическое определение платформы

```dart
import '../constants/platform_colors.dart';

// Автоматически получает правильный цвет для текущей платформы
Color primaryColor = PlatformColors.primary;
Color backgroundColor = PlatformColors.background;
```

### 3. Адаптивные стили

```dart
import '../utils/platform_utils.dart';

// Автоматически получает правильные стили для платформы
double elevation = PlatformUtils.adaptiveElevation;
double borderRadius = PlatformUtils.adaptiveBorderRadius;
EdgeInsets padding = PlatformUtils.adaptivePadding;
```

## Использование

### 1. Базовое использование цветов

```dart
import '../constants/platform_colors.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: PlatformColors.background,
      child: Text(
        'Привет, мир!',
        style: TextStyle(
          color: PlatformColors.textPrimary,
        ),
      ),
    );
  }
}
```

### 2. Использование адаптивных тем

```dart
import '../config/adaptive_theme.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AdaptiveTheme.lightTheme,
      darkTheme: AdaptiveTheme.darkTheme,
      // ...
    );
  }
}
```

### 3. Условное применение стилей

```dart
import '../utils/platform_utils.dart';

class AdaptiveCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: PlatformUtils.adaptiveElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          PlatformUtils.adaptiveBorderRadius,
        ),
      ),
      child: Container(
        padding: PlatformUtils.adaptivePadding,
        child: Text(
          'Адаптивная карточка',
          style: TextStyle(
            fontWeight: PlatformUtils.isIOS 
              ? FontWeight.w600 
              : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
```

### 4. Финансовые цвета

```dart
// Доходы и расходы с платформо-специфичными цветами
Container(
  color: PlatformColors.income, // Зеленый для доходов
  child: Text('+1,000 ₽'),
)

Container(
  color: PlatformColors.expense, // Красный для расходов
  child: Text('-500 ₽'),
)
```

## Цветовые схемы

### iOS (Human Interface Guidelines)

- **Primary**: `#007AFF` (iOS Blue)
- **Secondary**: `#5856D6` (iOS Purple)
- **Success**: `#34C759` (iOS Green)
- **Warning**: `#FF9500` (iOS Orange)
- **Error**: `#FF3B30` (iOS Red)
- **Background**: `#F2F2F7` (iOS Light Gray)
- **Surface**: `#FFFFFF` (iOS White)

### Android (Material Design)

- **Primary**: `#6200EE` (Material Purple)
- **Secondary**: `#03DAC6` (Material Teal)
- **Success**: `#4CAF50` (Material Green)
- **Warning**: `#FF9800` (Material Orange)
- **Error**: `#F44336` (Material Red)
- **Background**: `#FAFAFA` (Material Light Gray)
- **Surface**: `#FFFFFF` (Material White)

## Миграция с существующего кода

### Старый способ (не рекомендуется)

```dart
// ❌ Не используйте старые цвета
import '../constants/app_colors.dart';

Container(
  color: AppColors.primary, // Статический цвет
)
```

### Новый способ (рекомендуется)

```dart
// ✅ Используйте платформо-специфичные цвета
import '../constants/platform_colors.dart';

Container(
  color: PlatformColors.primary, // Адаптивный цвет
)
```

## Лучшие практики

### 1. Всегда используйте PlatformColors

```dart
// ✅ Правильно
Text(
  'Заголовок',
  style: TextStyle(color: PlatformColors.textPrimary),
)

// ❌ Неправильно
Text(
  'Заголовок',
  style: TextStyle(color: Colors.black),
)
```

### 2. Используйте адаптивные стили

```dart
// ✅ Правильно
Card(
  elevation: PlatformUtils.adaptiveElevation,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(
      PlatformUtils.adaptiveBorderRadius,
    ),
  ),
)

// ❌ Неправильно
Card(
  elevation: 4.0, // Статическое значение
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8.0), // Статическое значение
  ),
)
```

### 3. Учитывайте платформу при выборе шрифтов

```dart
// ✅ Правильно
Text(
  'Текст',
  style: TextStyle(
    fontWeight: PlatformUtils.isIOS 
      ? FontWeight.w600 
      : FontWeight.w500,
  ),
)
```

### 4. Используйте адаптивные темы

```dart
// ✅ Правильно
MaterialApp(
  theme: AdaptiveTheme.lightTheme,
  darkTheme: AdaptiveTheme.darkTheme,
)

// ❌ Неправильно
MaterialApp(
  theme: AppTheme.lightTheme, // Старая тема
)
```

## Отладка

### Проверка текущей платформы

```dart
import '../utils/platform_utils.dart';

print('Текущая платформа: ${PlatformUtils.platformName}');
print('Это iOS? ${PlatformUtils.isIOS}');
print('Это Android? ${PlatformUtils.isAndroid}');
```

### Проверка цветов

```dart
import '../constants/platform_colors.dart';

print('Primary color: ${PlatformColors.primary}');
print('Background color: ${PlatformColors.background}');
```

## Добавление новых цветов

### 1. Добавьте цвет в PlatformColors

```dart
// В lib/src/constants/platform_colors.dart

// iOS-специфичный цвет
static const Color _iosNewColor = Color(0xFF123456);

// Android-специфичный цвет
static const Color _androidNewColor = Color(0xFF654321);

// Геттер для получения правильного цвета
static Color get newColor => isIOS ? _iosNewColor : _androidNewColor;
```

### 2. Используйте новый цвет

```dart
Container(
  color: PlatformColors.newColor,
  child: Text('Новый цвет'),
)
```

## Заключение

Эта система обеспечивает:

- **Консистентность**: Все цвета соответствуют дизайн-системам платформ
- **Автоматизацию**: Не нужно вручную выбирать цвета для каждой платформы
- **Поддерживаемость**: Легко добавлять новые цвета и изменять существующие
- **Масштабируемость**: Система легко расширяется для новых платформ

Используйте эту систему для всех новых компонентов и постепенно мигрируйте существующий код. 