class CurrencyStats {
  final int amount; // В копейках/центах
  final int transactionsCount;
  final int transactionEntriesCount;

  const CurrencyStats({
    required this.amount,
    required this.transactionsCount,
    required this.transactionEntriesCount,
  });

  double get amountDecimal => amount / 100.0; // Преобразование в обычные единицы

  factory CurrencyStats.fromJson(Map<String, dynamic> json) {
    return CurrencyStats(
      amount: json['amount'] as int,
      transactionsCount: json['transactionsCount'] as int,
      transactionEntriesCount: json['transactionEntriesCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'transactionsCount': transactionsCount,
      'transactionEntriesCount': transactionEntriesCount,
    };
  }
}

class TransactionTypeStats {
  final Map<String, CurrencyStats> currencies;

  const TransactionTypeStats({
    required this.currencies,
  });

  factory TransactionTypeStats.fromJson(Map<String, dynamic> json) {
    final Map<String, CurrencyStats> currencies = {};
    json.forEach((currency, stats) {
      if (stats is Map<String, dynamic>) {
        currencies[currency] = CurrencyStats.fromJson(stats);
      }
    });
    return TransactionTypeStats(currencies: currencies);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};
    currencies.forEach((currency, stats) {
      result[currency] = stats.toJson();
    });
    return result;
  }
}

class TransactionStatsResponse {
  final TransactionTypeStats? expense;
  final TransactionTypeStats? income;

  const TransactionStatsResponse({
    this.expense,
    this.income,
  });

  factory TransactionStatsResponse.fromJson(Map<String, dynamic> json) {
    final totals = json['totals'] as Map<String, dynamic>? ?? {};
    
    return TransactionStatsResponse(
      expense: totals['expense'] != null 
          ? TransactionTypeStats.fromJson(totals['expense'] as Map<String, dynamic>)
          : null,
      income: totals['income'] != null 
          ? TransactionTypeStats.fromJson(totals['income'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totals': {
        if (expense != null) 'expense': expense!.toJson(),
        if (income != null) 'income': income!.toJson(),
      }
    };
  }
}
