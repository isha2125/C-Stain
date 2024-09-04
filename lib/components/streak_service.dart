import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StreakService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateStreak(String userId) async {
    final userDoc = _firestore.collection('user').doc(userId);
    final userData = await userDoc.get();

    final lastActionDate = userData['lastLoginDate']?.toDate();
    final currentDate = DateTime.now();

    if (lastActionDate == null || !_isSameDay(lastActionDate, currentDate)) {
      if (lastActionDate != null &&
          currentDate.difference(lastActionDate).inDays == 1) {
        // Increment streak
        await userDoc.update({
          'streak': FieldValue.increment(1),
          'lastLoginDate': currentDate,
        });
      } else {
        // Reset streak
        await userDoc.update({
          'streak': 1,
          'lastLoginDate': currentDate,
        });
      }
    }

    // Update last 7 days streak
    List<bool> last7Days = await _getLast7DaysStreak(userId);
    await userDoc.update({'last7DaysStreak': last7Days});
  }

  Future<List<bool>> _getLast7DaysStreak(String userId) async {
    final userDoc = await _firestore.collection('user').doc(userId).get();
    final lastActionDate = userDoc['lastLoginDate']?.toDate();
    final streak = userDoc['streak'] ?? 0;

    if (lastActionDate == null) return List.filled(7, false);

    List<bool> last7Days = List.filled(7, false);
    final currentDate = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final checkDate = currentDate.subtract(Duration(days: i));
      if (checkDate.difference(lastActionDate).inDays < streak) {
        last7Days[i] = true;
      } else {
        break;
      }
    }

    return last7Days;
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
      return last7DaysStreak?.cast<bool>() ?? List.filled(7, false);
    });
  }
}
