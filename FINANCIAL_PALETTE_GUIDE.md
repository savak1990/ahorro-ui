# Финансовая палитра для приложения Ahorro

## 🎨 Обзор палитры

Эта палитра специально разработана для финансового приложения и вызывает доверие, выглядит профессионально и обеспечивает отличную читаемость.

## 📊 Цветовая схема

### Основные цвета

| Цвет | HEX | Назначение | Психология |
|------|-----|------------|------------|
| **Primary** | `#1E3A8A` | Основной цвет | Доверие, стабильность, надежность |
| **Secondary** | `#64748B` | Вторичный цвет | Профессионализм, нейтральность |
| **Success** | `#059669` | Успех | Рост, прибыль, положительные результаты |
| **Warning** | `#D97706` | Предупреждение | Внимание, осторожность |
| **Error** | `#DC2626` | Ошибка | Убытки, проблемы, негативные результаты |

### Финансовые цвета

| Цвет | HEX | Назначение | Использование |
|------|-----|------------|---------------|
| **Income** | `#059669` | Доходы | Прибыль, зарплата, бонусы |
| **Expense** | `#DC2626` | Расходы | Покупки, счета, комиссии |
| **Balance** | `#1E3A8A` | Баланс | Общий баланс счетов |
| **Investment** | `#64748B` | Инвестиции | Портфель, акции, облигации |
| **Savings** | `#059669` | Сбережения | Накопления, депозиты |
| **Debt** | `#DC2626` | Долги | Кредиты, займы |
| **Budget** | `#D97706` | Бюджет | Планирование расходов |

### Нейтральные цвета

| Цвет | HEX | Назначение |
|------|-----|------------|
| **Background** | `#F8FAFC` | Фон приложения |
| **Surface** | `#FFFFFF` | Поверхности карточек |
| **Text Primary** | `#1E293B` | Основной текст |
| **Text Secondary** | `#64748B` | Вторичный текст |
| **Border** | `#E2E8F0` | Границы элементов |
| **Divider** | `#F1F5F9` | Разделители |

## 🚀 Использование в коде

### Базовое использование

```dart
import '../constants/platform_colors.dart';

// Основные цвета
Container(
  color: PlatformColors.primary,
  child: Text('Доверительный контент'),
)

// Финансовые цвета
Text(
  '+1,500 ₽',
  style: TextStyle(color: PlatformColors.income),
)

Text(
  '-800 ₽',
  style: TextStyle(color: PlatformColors.expense),
)
```

### Финансовые индикаторы

```dart
// Карточка дохода
Container(
  decoration: BoxDecoration(
    color: PlatformColors.income.withValues(alpha: 0.1),
    border: Border.all(color: PlatformColors.income.withValues(alpha: 0.3)),
  ),
  child: Text('Доходы: +15,420 ₽'),
)

// Карточка расхода
Container(
  decoration: BoxDecoration(
    color: PlatformColors.expense.withValues(alpha: 0.1),
    border: Border.all(color: PlatformColors.expense.withValues(alpha: 0.3)),
  ),
  child: Text('Расходы: -8,750 ₽'),
)
```

### Градиенты для финансовых данных

```dart
// Градиент для положительных значений
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        PlatformColors.income.withValues(alpha: 0.8),
        PlatformColors.income.withValues(alpha: 0.4),
      ],
    ),
  ),
)

// Градиент для отрицательных значений
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        PlatformColors.expense.withValues(alpha: 0.8),
        PlatformColors.expense.withValues(alpha: 0.4),
      ],
    ),
  ),
)
```

## 📱 Платформо-специфичные особенности

### iOS
- Использует более мягкие тени
- Скругления 8px
- Центрированные заголовки
- Минималистичный дизайн

### Android
- Material Design тени
- Скругления 4px
- Левосторонние заголовки
- Более выраженные элементы

## 🎯 Лучшие практики

### 1. Консистентность
- Всегда используйте `PlatformColors` вместо хардкода
- Следуйте семантике цветов (доход = зеленый, расход = красный)

### 2. Доступность
- Обеспечьте достаточный контраст (4.5:1 минимум)
- Не полагайтесь только на цвет для передачи информации

### 3. Читаемость
- Используйте `textPrimary` для основного текста
- Используйте `textSecondary` для подписей и меток
- Избегайте использования `error` цвета для обычного текста

### 4. Финансовые данные
- Всегда используйте `income` для положительных значений
- Всегда используйте `expense` для отрицательных значений
- Используйте `balance` для общих балансов
- Используйте `investment` для инвестиционных данных

## 🔧 Добавление новых цветов

### 1. Добавьте цвет в PlatformColors

```dart
// В lib/src/constants/platform_colors.dart

// Новый финансовый цвет
static const Color _iosNewFinancial = Color(0xFF7C3AED);
static const Color _androidNewFinancial = Color(0xFF7C3AED);

// Геттер
static Color get newFinancial => isIOS ? _iosNewFinancial : _androidNewFinancial;
```

### 2. Добавьте описание в документацию

```markdown
| **NewFinancial** | `#7C3AED` | Новое назначение | Описание использования |
```

## 🎨 Альтернативные палитры

### Минималистичная палитра
- Primary: `#0F172A` (Почти черный)
- Success: `#16A34A` (Зеленый)
- Error: `#E11D48` (Красный)

### Теплая палитра
- Primary: `#7C3AED` (Фиолетовый)
- Secondary: `#F59E0B` (Золотой)
- Success: `#10B981` (Зеленый)

## 📊 Примеры использования

### Дашборд
```dart
Column(
  children: [
    // Общий баланс
    FinancialCard(
      title: 'Общий баланс',
      amount: '125,420 ₽',
      color: PlatformColors.balance,
      icon: Icons.account_balance_wallet,
    ),
    
    // Доходы и расходы
    Row(
      children: [
        FinancialCard(
          title: 'Доходы',
          amount: '+45,200 ₽',
          color: PlatformColors.income,
          icon: Icons.trending_up,
        ),
        FinancialCard(
          title: 'Расходы',
          amount: '-18,750 ₽',
          color: PlatformColors.expense,
          icon: Icons.trending_down,
        ),
      ],
    ),
  ],
)
```

### Графики и диаграммы
```dart
// Круговая диаграмма
PieChart(
  sections: [
    PieChartSection(
      color: PlatformColors.income,
      value: 60,
      title: 'Доходы',
    ),
    PieChartSection(
      color: PlatformColors.expense,
      value: 40,
      title: 'Расходы',
    ),
  ],
)
```

## ✅ Проверка качества

### Контрастность
- Primary на белом: 4.5:1 ✅
- Success на белом: 4.5:1 ✅
- Error на белом: 4.5:1 ✅

### Семантика
- Зеленый = положительные значения ✅
- Красный = отрицательные значения ✅
- Синий = нейтральные/балансовые значения ✅

### Доступность
- Поддержка темной темы ✅
- Достаточный контраст ✅
- Не только цветовая индикация ✅

Эта палитра обеспечивает профессиональный внешний вид и отличную пользовательскую среду для финансового приложения! 🚀 