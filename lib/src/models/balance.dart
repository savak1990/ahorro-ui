class Balance {
  final String id;
  final String title;
  final String currency;

  Balance({required this.id, required this.title, required this.currency});

  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
      id: json['id'],
      title: json['title'],
      currency: json['currency'],
    );
  }
} 