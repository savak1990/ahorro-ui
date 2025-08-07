# Руководство по миграции на платформо-специфичные цвета

## Что уже сделано ✅

1. **Обновлен main.dart** - теперь использует `AdaptiveTheme` вместо `AppTheme`
2. **Создан демо-виджет** - `PlatformDemoWidget` показывает все платформо-специфичные цвета
3. **Обновлен MonthlyOverviewCard** - использует новые цвета для доходов/расходов
4. **Добавлен в главный экран** - демо-виджет отображается на главной странице

## Как проверить результат 🎯

1. Запустите приложение: `flutter run`
2. Откройте главный экран
3. Прокрутите вниз до секции "Платформо-специфичные цвета"
4. Увидите:
   - Индикатор текущей платформы (iOS/Android)
   - Демонстрацию всех цветов с их HEX-кодами
   - Финансовые цвета (доход/расход)
   - Адаптивные кнопки

## Что изменилось в цветах 🎨

### iOS (Human Interface Guidelines)
- **Основной**: `#007AFF` (iOS Blue)
- **Доход**: `#34C759` (iOS Green)  
- **Расход**: `#FF3B30` (iOS Red)

### Android (Material Design)
- **Основной**: `#6200EE` (Material Purple)
- **Доход**: `#4CAF50` (Material Green)
- **Расход**: `#F44336` (Material Red)

## Следующие шаги для полной миграции 📋

### 1. Обновить импорты в существующих файлах

```dart
// ❌ Старый способ
import '../constants/app_colors.dart';

// ✅ Новый способ  
import '../constants/platform_colors.dart';
import '../utils/platform_utils.dart';
```

### 2. Заменить цвета в виджетах

```dart
// ❌ Старый способ
Container(
  color: AppColors.primary,
  child: Text('Текст', style: TextStyle(color: AppColors.textPrimary)),
)

// ✅ Новый способ
Container(
  color: PlatformColors.primary,
  child: Text('Текст', style: TextStyle(color: PlatformColors.textPrimary)),
)
```

### 3. Использовать адаптивные стили

```dart
// ❌ Старый способ
Card(
  elevation: 4.0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
)

// ✅ Новый способ
Card(
  elevation: PlatformUtils.adaptiveElevation,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(PlatformUtils.adaptiveBorderRadius),
  ),
)
```

## Файлы для обновления 🔄

### Приоритет 1 (высокий)
- `lib/src/widgets/transaction_tile.dart`
- `lib/src/widgets/balance_tile.dart`
- `lib/src/widgets/expense_transaction_form.dart`
- `lib/src/widgets/income_transaction_form.dart`

### Приоритет 2 (средний)
- `lib/src/widgets/category_picker_dialog.dart`
- `lib/src/widgets/filters_bottom_sheet.dart`
- `lib/src/widgets/date_filter_bottom_sheet.dart`

### Приоритет 3 (низкий)
- `lib/src/widgets/error_state_widget.dart`
- `lib/src/widgets/platform_loading_indicator.dart`

## Команды для проверки ✅

```bash
# Проверить синтаксис
flutter analyze

# Запустить на Android
flutter run -d android

# Запустить на iOS (если доступен)
flutter run -d ios

# Запустить на веб
flutter run -d chrome
```

## Отладка 🐛

Если возникают ошибки:

1. **Проверьте импорты** - убедитесь, что импортированы все необходимые файлы
2. **Проверьте синтаксис** - запустите `flutter analyze`
3. **Очистите кэш** - `flutter clean && flutter pub get`
4. **Перезапустите** - `flutter run`

## Результат 🎉

После полной миграции ваше приложение будет:
- Автоматически использовать правильные цвета для каждой платформы
- Следовать дизайн-системам iOS и Android
- Иметь консистентный внешний вид
- Легко поддерживаться и расширяться 