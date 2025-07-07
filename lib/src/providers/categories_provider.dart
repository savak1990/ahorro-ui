import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class CategoriesProvider extends ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Category? get defaultCategory {
    if (_categories.isEmpty) return null;
    return _categories.reduce((a, b) => a.rank < b.rank ? a : b);
  }

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await ApiService.getCategories();
      _categories = response.categories;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
} 