class AppConfig {
  // Get URL from environment variables passed during build.
  // Use the URL you provided as the default value.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api-ahorro-transactions-savak.vkdev1.com/transactions',
  );
} 