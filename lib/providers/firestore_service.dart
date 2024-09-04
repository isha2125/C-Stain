import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/components/streak_service.dart';
import 'package:cstain/models/achievements.dart';
import 'package:cstain/models/categories_and_action.dart';
import 'package:cstain/models/user.dart';
import 'package:cstain/models/user_contribution.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreakService _streakService = StreakService();
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
      final contributionData = contribution.toMap();

      // For food actions, the co2_saved is already calculated
      if (contribution.category == 'Food') {
        contributionData['co2_saved'] = contribution.co2_saved.toDouble();
      } else {
        // For non-food actions, keep the existing calculation
        final actionDoc = await _firestore
            .collection('categories_and_actions')
            .where('action_name', isEqualTo: contribution.action)
            .limit(1)
            .get();

        if (actionDoc.docs.isNotEmpty) {
          final actionData = actionDoc.docs.first.data();
          final co2SavingFactor =
              (actionData['co2_saving_factor'] as num).toDouble();
          final durationInHours = contribution.duration / 60;
          contributionData['co2_saved'] =
              (durationInHours * co2SavingFactor).toDouble();
          contributionData['duration'] = durationInHours.toDouble();
        }
      }

      contributionData['created_at'] = FieldValue.serverTimestamp();

      await _firestore.collection('user_contributions').add(contributionData);
      final userDoc =
          await _firestore.collection('user').doc(contribution.user_id).get();
      final userData =
          UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      final newTotal = userData.total_CO2_saved + contributionData['co2_saved'];
      await updateUserCO2Saved(contribution.user_id, newTotal);
      await _streakService.updateStreak(contribution.user_id);
      print(
          'User contribution added successfully with CO2 saved: ${contributionData['co2_saved']}');
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

  Future<UserModel> fetchUserData(String userId) async {
    try {
      final userDoc = await _firestore.collection('user').doc(userId).get();
      return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching user data: $e');
      throw e;
    }
  }

  Future<void> updateUserCO2Saved(String userId, double newTotal) async {
    try {
      await _firestore.collection('user').doc(userId).update({
        'total_CO2_saved': newTotal,
      });
    } catch (e) {
      print('Error updating user CO2 saved: $e');
      throw e;
    }
  }

  Stream<UserModel> getUserStream(String userId) {
    return _firestore.collection('user').doc(userId).snapshots().map(
        (snapshot) =>
            UserModel.fromMap(snapshot.data() as Map<String, dynamic>));
  }

  Future<List<AchievementsModel>> fetchAchievements() async {
    try {
      final snapshot = await _firestore.collection('achievements').get();
      return snapshot.docs
          .map((doc) => AchievementsModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching achievements: $e');
      return [];
    }
  }

  Future<void> deleteUserContribution(
      UserContributionModel contribution) async {
    try {
      // Delete the contribution document
      await _firestore
          .collection('user_contributions')
          .doc(contribution.contribution_id)
          .delete();

      // Update user's total CO2 saved
      final userDoc =
          await _firestore.collection('user').doc(contribution.user_id).get();
      final userData =
          UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      final newTotal = userData.total_CO2_saved - contribution.co2_saved;
      await updateUserCO2Saved(contribution.user_id, newTotal);

      print('User contribution deleted successfully');
    } catch (e) {
      print('Error deleting user contribution: $e');
      throw e;
    }
  }
}
