import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StreakService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateStreak() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = _firestore.collection('user').doc(user.uid);
    final userData = await userDoc.get();

    final lastLoginDate = userData['lastLoginDate']?.toDate();
    final currentDate = DateTime.now();

    if (lastLoginDate == null || !_isSameDay(lastLoginDate, currentDate)) {
      if (lastLoginDate != null &&
          currentDate.difference(lastLoginDate).inDays == 1) {
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
    List<bool> last7Days = List.filled(7, false);
    last7Days[0] = true; // Today is always true
    for (int i = 1; i < 7; i++) {
      final checkDate = currentDate.subtract(Duration(days: i));
      final isStreakDay = await _isStreakDay(user.uid, checkDate);
      last7Days[i] = isStreakDay;
    }
    await userDoc.update({'last7DaysStreak': last7Days});
  }

  Future<bool> _isStreakDay(String userId, DateTime date) async {
    final userDoc = await _firestore.collection('user').doc(userId).get();
    final lastLoginDate = userDoc['lastLoginDate']?.toDate();
    if (lastLoginDate == null) return false;
    return _isSameDay(lastLoginDate, date) || lastLoginDate.isAfter(date);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Stream<List<bool>> getLastSevenDaysStreakStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(List.filled(7, false));

    return _firestore
        .collection('user')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) {
      final lastLoginDate = snapshot.data()?['lastLoginDate']?.toDate();
      final streak = snapshot.data()?['streak'] ?? 0;

      if (lastLoginDate == null) return List.filled(7, false);

      List<bool> lastSevenDays = List.filled(7, false);
      final currentDate = DateTime.now();

      for (int i = 0; i < 7; i++) {
        final day = currentDate.subtract(Duration(days: i));
        if (day.difference(lastLoginDate).inDays < streak) {
          lastSevenDays[6 - i] = true;
        } else {
          break;
        }
      }

      return lastSevenDays;
    });
  }
}
