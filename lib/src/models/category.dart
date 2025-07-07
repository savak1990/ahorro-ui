class Category {
  final String categoryId;
  final String name;
  final String description;
  final String? imageUrl;
  final int rank;
  final String categoryGroupId;
  final String categoryGroupName;
  final String? categoryGroupImageUrl;
  final int categoryGroupRank;

  Category({
    required this.categoryId,
    required this.name,
    required this.description,
    required this.rank,
    required this.categoryGroupId,
    required this.categoryGroupName,
    required this.categoryGroupRank,
    this.imageUrl,
    this.categoryGroupImageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['categoryId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      rank: json['rank'] ?? 0,
      categoryGroupId: json['categoryGroupId'] ?? '',
      categoryGroupName: json['categoryGroupName'] ?? '',
      categoryGroupImageUrl: json['categoryGroupImageUrl'],
      categoryGroupRank: json['categoryGroupRank'] ?? 0,
    );
  }

  // Геттеры для обратной совместимости
  String get id => categoryId;
  String get groupId => categoryGroupId;
  String get groupName => categoryGroupName;
  int get groupIndex => categoryGroupRank;
} 