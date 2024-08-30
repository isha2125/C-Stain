import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/models/categories_and_action.dart';

class CategoriesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CategoriesAndActionModel>> fetchCategoriesAndActions() async {
    final snapshot =
        await _firestore.collection('categories_and_actions').get();
    return snapshot.docs
        .map((doc) => CategoriesAndActionModel.fromMap(doc.data()))
        .toList();
  }
}
