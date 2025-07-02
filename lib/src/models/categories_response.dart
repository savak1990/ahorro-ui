import 'category_data.dart';

class CategoriesResponse {
  final List<CategoryData> categories;
  final String? nextToken;

  CategoriesResponse({
    required this.categories,
    this.nextToken,
  });

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List? ?? [];
    return CategoriesResponse(
      categories: items.map((item) => CategoryData.fromJson(item)).toList(),
      nextToken: json['nextToken'],
    );
  }
} 