import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class CategoriesProvider extends ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  CategoriesProvider() {
    debugPrint('[CategoriesProvider] constructor called');
  }

  List<Category> get categories {
    debugPrint('[CategoriesProvider] get categories: ${_categories.length}');
    return _categories;
  }
  bool get isLoading {
    debugPrint('[CategoriesProvider] get isLoading: $_isLoading');
    return _isLoading;
  }
  String? get error {
    debugPrint('[CategoriesProvider] get error: $_error');
    return _error;
  }

  Category? get defaultCategory {
    if (_categories.isEmpty) return null;
    return _categories.reduce((a, b) => a.rank < b.rank ? a : b);
  }

  Future<void> loadCategories() async {
    debugPrint('[CategoriesProvider] loadCategories called');
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await ApiService.getCategories();
      _categories = response.categories;
      debugPrint('[CategoriesProvider] loaded ${_categories.length} categories');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      debugPrint('[CategoriesProvider] error: $_error');
      notifyListeners();
    }
  }
} 