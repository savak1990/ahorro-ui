enum TransactionStatsType { expense, income }

enum TransactionStatsGrouping { categories, month, week, day, balance }

class TransactionStatsItem {
  // The value of specific grouping, e.g., category name, month name
  final String label;
  final int amount;
  final String currency;
  final String? icon; // Make icon optional

  const TransactionStatsItem({
    required this.label,
    required this.amount,
    required this.currency,
    this.icon,
  });

  factory TransactionStatsItem.fromJson(Map<String, dynamic> json) {
    return TransactionStatsItem(
      icon: json['icon'] as String?, // Handle null values
      label: json['label'] as String,
      amount: json['amount'] as int,
      currency: json['currency'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'icon': icon, // Include icon only if it's not null
      'label': label,
      'amount': amount,
      'currency': currency,
    };
  }
}

class TransactionStatsResponse {
  final List<TransactionStatsItem>? items;

  const TransactionStatsResponse({this.items});

  factory TransactionStatsResponse.fromJson(Map<String, dynamic> json) {
    return TransactionStatsResponse(
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => TransactionStatsItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'items': items?.map((item) => item.toJson()).toList()};
  }
}
