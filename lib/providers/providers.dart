import 'package:cstain/models/categories_and_action.dart';
import 'package:cstain/providers/firestore_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoriesProvider =
    FutureProvider<List<CategoriesAndActionModel>>((ref) async {
  try {
    final repository = CategoriesRepository();
    final categories = await repository.fetchCategoriesAndActions();
    print('Fetched categories: $categories');
    return categories;
  } catch (e) {
    print('Error in categoriesProvider: $e');
    rethrow;
  }
});
