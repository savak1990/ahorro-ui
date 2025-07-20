class Merchant {
  final String merchantId;
  final String groupId;
  final String userId;
  final String name;
  final String description;
  final String imageUrl;
  final int rank;
  final DateTime createdAt;
  final DateTime updatedAt;

  Merchant({
    required this.merchantId,
    required this.groupId,
    required this.userId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rank,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      merchantId: json['merchantId'] as String,
      groupId: json['groupId'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      rank: json['rank'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'merchantId': merchantId,
    'groupId': groupId,
    'userId': userId,
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'rank': rank,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
} 