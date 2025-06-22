class AppConfig {
  // Получаем URL из переменных окружения, переданных при сборке.
  // Используем URL, который вы предоставили, как значение по умолчанию.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api-ahorro-transactions-savak.vkdev1.com/transactions',
  );
} 