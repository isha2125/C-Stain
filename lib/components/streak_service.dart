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
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Stream<int> getStreakStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);

    return _firestore
        .collection('user')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.data()?['streak'] ?? 0;
    });
  }
}
