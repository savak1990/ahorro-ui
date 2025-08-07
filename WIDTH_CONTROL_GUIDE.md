# 🎯 Руководство по контролю ширины компонентов

## 📋 **Проблема**
Разная ширина между `MonthlyOverviewCard` и списком транзакций из-за несогласованных отступов.

## 🔧 **Решение**

### 1. **Централизованные константы** (`lib/src/constants/app_constants.dart`)

```dart
class AppConstants {
  // Отступы
  static const double screenPadding = 16.0;        // Основной отступ экрана
  static const double horizontalPadding = 16.0;    // Горизонтальные отступы для списков
  static const double cardPadding = 16.0;          // Отступ карточек
  static const double listItemPadding = 8.0;       // Отступ элементов списка
  
  // Радиусы скругления
  static const double cardBorderRadius = 12.0;     // Радиус карточек
  static const double buttonBorderRadius = 8.0;    // Радиус кнопок
}
```

### 2. **Переиспользуемые контейнеры** (`lib/src/widgets/screen_container.dart`)

#### **ScreenContainer** - для основных экранов
```dart
ScreenContainer(
  child: Column(
    children: [
      MonthlyOverviewCard(...),
      // другие виджеты
    ],
  ),
)
```

#### **ListContainer** - для списков
```dart
ListContainer(
  child: ListView(
    children: [
      TransactionTile(...),
      // другие элементы списка
    ],
  ),
)
```

### 3. **Применение в экранах**

#### **HomeScreen** (до):
```dart
return Padding(
  padding: const EdgeInsets.all(16.0),  // ← Жестко заданный отступ
  child: Column(...),
);
```

#### **HomeScreen** (после):
```dart
return CustomScrollView(
  slivers: [
    SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.horizontalPadding,  // ← Единообразные горизонтальные отступы
          vertical: 8,
        ),
        child: MonthlyOverviewCard(...),
      ),
    ),
  ],
);
```

#### **TransactionsScreen** (до):
```dart
SliverPadding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),  // ← Разные отступы
  sliver: SliverList(...),
)
```

#### **TransactionsScreen** (после):
```dart
SliverPadding(
  padding: const EdgeInsets.symmetric(
    horizontal: AppConstants.horizontalPadding,  // ← Единообразные горизонтальные отступы
    vertical: 8,
  ),
  sliver: SliverList(...),
)
```

## 🎨 **Как контролировать ширину**

### **1. Изменение глобальных отступов**
Отредактируйте `AppConstants.horizontalPadding`:
```dart
static const double horizontalPadding = 20.0;  // Увеличить горизонтальные отступы
static const double horizontalPadding = 12.0;  // Уменьшить горизонтальные отступы
```

### **2. Переопределение для конкретного экрана**
```dart
ScreenContainer(
  padding: EdgeInsets.all(24.0),  // Специальный отступ
  child: YourWidget(),
)
```

### **3. Отключение отступов**
```dart
ScreenContainer(
  useDefaultPadding: false,  // Без отступов
  child: YourWidget(),
)
```

### **4. Адаптивные отступы**
```dart
ScreenContainer(
  padding: EdgeInsets.symmetric(
    horizontal: MediaQuery.of(context).size.width * 0.05,  // 5% от ширины экрана
    vertical: 16,
  ),
  child: YourWidget(),
)
```

## 📱 **Рекомендации по отступам**

### **Мобильные устройства:**
- **Экран:** 16px
- **Карточки:** 16px
- **Элементы списка:** 8px

### **Планшеты:**
- **Экран:** 24px
- **Карточки:** 20px
- **Элементы списка:** 12px

### **Десктоп:**
- **Экран:** 32px
- **Карточки:** 24px
- **Элементы списка:** 16px

## 🔍 **Проверка единообразия**

### **Визуальная проверка:**
1. Откройте HomeScreen и TransactionsScreen
2. Сравните ширину MonthlyOverviewCard и списка транзакций
3. Они должны быть одинаковыми

### **Код-ревью:**
1. Проверьте использование `AppConstants.screenPadding`
2. Убедитесь, что нет жестко заданных значений отступов
3. Используйте `ScreenContainer` и `ListContainer` где возможно

## 🚀 **Преимущества решения**

✅ **Единообразие** - одинаковые отступы везде  
✅ **Поддерживаемость** - изменения в одном месте  
✅ **Гибкость** - легко настраивать для разных экранов  
✅ **Масштабируемость** - легко добавлять новые экраны  
✅ **Адаптивность** - можно настроить для разных устройств  

## 📝 **Чек-лист для новых экранов**

- [ ] Используйте `AppConstants.screenPadding` для отступов
- [ ] Примените `ScreenContainer` для основного контента
- [ ] Используйте `ListContainer` для списков
- [ ] Проверьте визуальное соответствие с другими экранами
- [ ] Добавьте адаптивные отступы для планшетов/десктопа при необходимости 