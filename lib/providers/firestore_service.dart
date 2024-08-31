import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/models/categories_and_action.dart';

class CategoriesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<CategoriesAndActionModel>> fetchCategoriesAndActions() async {
    try {
      final snapshot =
          await _firestore.collection('categories_and_actions').get();
      final categories = snapshot.docs
          .map((doc) => CategoriesAndActionModel.fromMap(doc.data()))
          .toList();

      print("Fetched ${categories.length} categories from Firestore");
      categories.forEach((category) {
        print(
            "Category: ${category.category_name}, Action: ${category.action_name}");
      });

      return categories;
    } catch (e) {
      print('Error fetching categories and actions: $e');
      return [];
    }
  }
}
