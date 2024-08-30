import 'package:cstain/models/categories_and_action.dart';
import 'package:cstain/providers/firestore_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoriesProvider =
    FutureProvider<List<CategoriesAndActionModel>>((ref) async {
  final repository = CategoriesRepository();
  return repository.fetchCategoriesAndActions();
});
