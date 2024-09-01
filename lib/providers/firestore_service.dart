import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/models/categories_and_action.dart';
import 'package:cstain/models/user_contribution.dart';

class FirestoreService {
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

  Future<void> addUserContribution(UserContributionModel contribution) async {
    try {
      final durationInHours = contribution.duration / 60;
      final contributionData = contribution.toMap();
      contributionData['created_at'] = FieldValue.serverTimestamp();

      await _firestore.collection('user_contributions').add(contributionData);
      print('User contribution added successfully');
    } catch (e) {
      print('Error adding user contribution: $e');
    }
  }

  Future<List<UserContributionModel>> fetchTodayUserContributions(
      String userId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('user_contributions')
          .where('user_id', isEqualTo: userId)
          .where('created_at',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('created_at', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => UserContributionModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching today\'s user contributions: $e');
      return [];
    }
  }
}
