class CategoryData {
  final String id;
  final String name;
  final String groupId;
  final String groupName;
  final int groupIndex;
  final String? imageUrl;

  CategoryData({
    required this.id,
    required this.name,
    required this.groupId,
    required this.groupName,
    required this.groupIndex,
    this.imageUrl,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      groupId: json['groupId'] ?? '',
      groupName: json['groupName'] ?? '',
      groupIndex: json['groupIndex'] ?? 0,
      imageUrl: json['imageUrl'],
    );
  }
} 