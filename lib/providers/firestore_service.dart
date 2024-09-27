import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cstain/models/achievements.dart';
import 'package:cstain/models/badges.dart';
import 'package:cstain/models/categories_and_action.dart';
import 'package:cstain/models/user.dart';
import 'package:cstain/models/user_achievement.dart';
import 'package:cstain/models/user_badges.dart';
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
      await updateStreak(userData.uid);
      print('i am trying to fix streak');

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
          .map((doc) => UserContributionModel.fromMap(
              {...doc.data(), 'contribution_id': doc.id}))
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

  Future<void> updateStreak(String userId) async {
    // Get the user's document from Firestore
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('user').doc(userId).get();

    if (userDoc.exists) {
      // Fetch current streak and last activity date
      Timestamp lastActivityTimestamp = userDoc['lastActivityDate'];
      int currentStreak = userDoc['currentStreak'] ?? 0;

      DateTime lastActivityDate = lastActivityTimestamp.toDate();
      DateTime today = DateTime.now();

      // Calculate the difference in days between today and the last logged activity
      int daysDifference = today.difference(lastActivityDate).inDays;

      // Fetch or initialize weekly streak data (default to false for each day)
      Map<String, bool> weeklyStreak = {
        'Sunday': userDoc['streak_sunday'] ?? false,
        'Monday': userDoc['streak_monday'] ?? false,
        'Tuesday': userDoc['streak_tuesday'] ?? false,
        'Wednesday': userDoc['streak_wednesday'] ?? false,
        'Thursday': userDoc['streak_thursday'] ?? false,
        'Friday': userDoc['streak_friday'] ?? false,
        'Saturday': userDoc['streak_saturday'] ?? false,
      };

      // If it's a consecutive day, increment the streak
      if (daysDifference == 0) {
        // Same day action, don't change the streak
        print("Action already logged today");
      } else if (daysDifference == 1) {
        // Increment streak for consecutive day
        currentStreak += 1;
      } else if (daysDifference > 1) {
        // Reset streak and optionally the weekly streak
        currentStreak = 1;
        weeklyStreak.updateAll((key, value) => false);
      }

      // Update the streak for today in the weekly streak data
      String todayDay = _getDayOfWeek(today);
      weeklyStreak[todayDay] = true;

      // Update Firestore with the new streak and weekly streak values
      await FirebaseFirestore.instance.collection('user').doc(userId).update({
        'currentStreak': currentStreak,
        'lastActivityDate': Timestamp.fromDate(today),
        'streak_sunday': weeklyStreak['Sunday'],
        'streak_monday': weeklyStreak['Monday'],
        'streak_tuesday': weeklyStreak['Tuesday'],
        'streak_wednesday': weeklyStreak['Wednesday'],
        'streak_thursday': weeklyStreak['Thursday'],
        'streak_friday': weeklyStreak['Friday'],
        'streak_saturday': weeklyStreak['Saturday'],
      });
      await checkAndAwardBadges(userId, currentStreak);
    } else {
      // If document doesn't exist, initialize the streak for the first action
      DateTime today = DateTime.now();
      String todayDay = _getDayOfWeek(today);

      await FirebaseFirestore.instance.collection('user').doc(userId).set({
        'currentStreak': 1,
        'lastActivityDate': Timestamp.fromDate(today),
        'streak_sunday': todayDay == 'Sunday',
        'streak_monday': todayDay == 'Monday',
        'streak_tuesday': todayDay == 'Tuesday',
        'streak_wednesday': todayDay == 'Wednesday',
        'streak_thursday': todayDay == 'Thursday',
        'streak_friday': todayDay == 'Friday',
        'streak_saturday': todayDay == 'Saturday',
      });
      await checkAndAwardBadges(userId, 1);
    }
  }

// Helper function to get the name of the day
  String _getDayOfWeek(DateTime date) {
    List<String> days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    return days[date.weekday % 7];
  }

  Future<void> storeUserAchievement(String userId, String achievementId) async {
    try {
      final userAchievement = UserAchievementsModel(
        achievement_id: achievementId,
        earned_at: Timestamp.now(),
        user_id: userId,
      );

      await _firestore
          .collection('user_achievements')
          .add(userAchievement.toMap());
      print('Achievement stored successfully');
    } catch (e) {
      print('Error storing achievement: $e');
    }
  }

  Future<bool> hasUserAchievement(String userId, String achievementId) async {
    final querySnapshot = await _firestore
        .collection('user_achievements')
        .where('user_id', isEqualTo: userId)
        .where('achievement_id', isEqualTo: achievementId)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<List<BadgesModel>> fetchBadges() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('badges').get();
      return snapshot.docs
          .map((doc) => BadgesModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching badges: $e');
      return [];
    }
  }

  Future<bool> hasUserBadge(String userId, String badgeId) async {
    final querySnapshot = await _firestore
        .collection('user_badges')
        .where('user_id', isEqualTo: userId)
        .where('badge_id', isEqualTo: badgeId)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> checkAndAwardBadges(String userId, int currentStreak) async {
    try {
      print('are we here ?');
      final badges = await fetchBadges();
      print('Fetched badges: $badges');
      final eligibleBadges =
          badges.where((badge) => currentStreak >= badge.time_period).toList();
      print('Eligible badges: $eligibleBadges');
      for (var badge in eligibleBadges) {
        final checkUserHasBadge = await hasUserBadge(userId, badge.badge_id);
        print('User $userId has badge ${badge.badge_id}: $checkUserHasBadge');

        if (!checkUserHasBadge) {
          await storeUserBadge(userId, badge.badge_id);
          print('Stored badge ${badge.badge_id} for user $userId');

          print(
              'Awarded badge ${badge.name} to user $userId for $currentStreak day streak');
        }
      }
    } catch (e) {
      print('Error checking and awarding badges: $e');
    }
  }

  Future<void> storeUserBadge(String userId, String badgeId) async {
    try {
      print('stroing user badges');
      final userBadge = UserBadgesModel(
        badge_id: badgeId,
        earned_at: Timestamp.now(),
        user_id: userId,
      );

      await _firestore.collection('user_badges').add(userBadge.toMap());
      print('Badge stored successfully');
    } catch (e) {
      print('Error storing badge: $e');
    }
  }

  Stream<List<UserBadgesModel>> getUserBadgesStream(String userId) {
    return _firestore
        .collection('user_badges')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserBadgesModel.fromMap(doc.data()))
            .toList());
  }

  Future<UserAchievementsModel?> fetchLatestUserAchievement(
      String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('user_achievements')
          .where('user_id', isEqualTo: userId)
          .orderBy('earned_at', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return UserAchievementsModel.fromMap(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      print('Error fetching latest user achievement: $e');
      return null;
    }
  }

  Future<AchievementsModel?> fetchAchievementById(String achievementId) async {
    try {
      final doc =
          await _firestore.collection('achievements').doc(achievementId).get();
      if (doc.exists) {
        return AchievementsModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error fetching achievement by ID: $e');
      return null;
    }
  }

  Stream<List<Map<String, dynamic>>> getUserAchievementsWithDetailsStream(
      String userId) {
    return _firestore
        .collection('user_achievements')
        .where('user_id', isEqualTo: userId)
        .orderBy('earned_at', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> achievementsWithDetails = [];
      for (var doc in snapshot.docs) {
        final userAchievement = UserAchievementsModel.fromMap(doc.data());
        final achievementDoc = await _firestore
            .collection('achievements')
            .doc(userAchievement.achievement_id)
            .get();
        if (achievementDoc.exists) {
          final achievement = AchievementsModel.fromMap(achievementDoc.data()!);
          achievementsWithDetails.add({
            ...userAchievement.toMap(),
            'name': achievement.name,
            'description': achievement.description,
          });
        }
      }
      return achievementsWithDetails;
    });
  }
}
