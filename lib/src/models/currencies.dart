enum CurrencyCode { usd, eur, gbp, jpy, aud, uah, byn }

CurrencyCode toCurrencyCode(String input) {
  final code = input.toUpperCase().trim();
  return CurrencyCode.values.firstWhere(
    (e) => e.toString().split('.').last == code,
    orElse: () => CurrencyCode.usd, // Default to USD if not found
  );
}

String fromCurrencyCode(CurrencyCode code) {
  return code.toString().split('.').last.toUpperCase();
}

String getCurrencySymbol(CurrencyCode currency) {
  switch (currency) {
    case CurrencyCode.usd:
      return '\$';
    case CurrencyCode.eur:
      return '€';
    case CurrencyCode.gbp:
      return '£';
    case CurrencyCode.jpy:
      return '¥';
    case CurrencyCode.aud:
      return 'A\$';
    case CurrencyCode.uah:
      return '₴';
    case CurrencyCode.byn:
      return 'Br';
  }
}

String formatAmountInt(int amount, CurrencyCode currency) {
  final symbol = getCurrencySymbol(currency);
  final formattedAmount = (amount / 100).toStringAsFixed(2);
  return '$symbol$formattedAmount';
}

String formatAmountDouble(double amount, CurrencyCode currency) {
  final symbol = getCurrencySymbol(currency);
  return '$symbol${amount.toStringAsFixed(2)}';
}
