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

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Category? get defaultCategory {
    if (_categories.isEmpty) return null;
    return _categories.reduce((a, b) => a.rank < b.rank ? a : b);
  }

  Future<void> loadCategories() async {
    debugPrint('[CategoriesProvider] loadCategories called');
    await _executeAsyncOperation(() async {
      final response = await ApiService.getCategories();
      _categories = response.categories;
      debugPrint('[CategoriesProvider]: Loaded ${_categories.length} categories');
    });
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _executeAsyncOperation(Future<void> Function() operation) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await operation();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _error = error;
    debugPrint('[CategoriesProvider]: error: $_error');
  }
} 