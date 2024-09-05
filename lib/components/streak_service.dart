import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StreakService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateStreak(String userId) async {
    final userDoc = _firestore.collection('user').doc(userId);
    final userData = await userDoc.get();

    final currentDate = DateTime.now();
    final currentWeekDay =
        currentDate.weekday % 7; // 0 for Sunday, 6 for Saturday

    List<bool> weekStreak =
        List.from(userData['weekStreak'] ?? List.filled(7, false));

    // Update the current day in the weekStreak
    weekStreak[currentWeekDay] = true;

    // Reset streak if it's a new week (Sunday)
    if (currentWeekDay == 0) {
      weekStreak = List.filled(7, false);
      weekStreak[0] = true;
    }

    await userDoc.update({
      'weekStreak': weekStreak,
      'lastLoginDate': currentDate,
    });
  }

  Stream<List<bool>> getWeekStreakStream(String userId) {
    return _firestore
        .collection('user')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      final weekStreak = snapshot.data()?['weekStreak'] as List?;
      return weekStreak?.cast<bool>() ?? List.filled(7, false);
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Stream<List<bool>> getLastSevenDaysStreakStream(String userId) {
    return _firestore
        .collection('user')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      final last7DaysStreak = snapshot.data()?['last7DaysStreak'] as List?;
      List<bool> streak =
          last7DaysStreak?.cast<bool>() ?? List.filled(7, false);

      // Ensure the streak starts from Sunday
      final today = DateTime.now();
      final daysUntilSunday = (7 - today.weekday) % 7;
      final sundayStreak = List<bool>.filled(7, false);
      for (int i = 0; i < 7; i++) {
        final index = (i + daysUntilSunday) % 7;
        sundayStreak[i] = index < streak.length ? streak[index] : false;
      }

      return sundayStreak;
    });
  }
}
