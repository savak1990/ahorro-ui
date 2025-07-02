class TransactionEntry {
  final String description;
  final double amount;
  final String categoryId;

  TransactionEntry({
    required this.description,
    required this.amount,
    required this.categoryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amount': (amount * 100).round().toDouble(), // Multiply by 100 for storage in cents
      'categoryId': categoryId,
    };
  }
} 