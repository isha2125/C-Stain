import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Define the streakProvider to get the current streak count
final streakProvider = StreamProvider<int>((ref) {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    // Return a stream with 0 if no user is logged in
    return Stream.value(0);
  }

  final userId = user.uid;

  // Listen for real-time updates in Firestore
  return FirebaseFirestore.instance
      .collection('user')
      .doc(userId)
      .snapshots()
      .map((userDoc) {
    if (userDoc.exists) {
      final streak = userDoc.data()?['currentStreak'] ?? 0;
      return streak;
    } else {
      return 0;
    }
  });
});

final weeklyStreakProvider = StreamProvider<Map<String, bool>>((ref) {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return Stream.value({});
  }

  final userId = user.uid;

  // Listen for real-time updates in Firestore
  return FirebaseFirestore.instance
      .collection('user')
      .doc(userId)
      .snapshots()
      .map((userDoc) {
    if (userDoc.exists) {
      return {
        'Sunday': userDoc.data()?['streak_sunday'] ?? false,
        'Monday': userDoc.data()?['streak_monday'] ?? false,
        'Tuesday': userDoc.data()?['streak_tuesday'] ?? false,
        'Wednesday': userDoc.data()?['streak_wednesday'] ?? false,
        'Thursday': userDoc.data()?['streak_thursday'] ?? false,
        'Friday': userDoc.data()?['streak_friday'] ?? false,
        'Saturday': userDoc.data()?['streak_saturday'] ?? false,
      };
    } else {
      return {};
    }
  });
});

class StreakWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStreak = ref.watch(streakProvider);
    final weeklyStreakAsync = ref.watch(weeklyStreakProvider);

    return Column(
      children: [
        asyncStreak.when(
          data: (streak) => Container(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '🔥 Streak: $streak Days',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          loading: () => Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error: $err'),
        ),
        SizedBox(height: 16.0),
        weeklyStreakAsync.when(
          data: (weeklyStreak) {
            return _buildWeeklyStreakView(weeklyStreak);
          },
          loading: () => CircularProgressIndicator(),
          error: (err, stack) => Text('Error: $err'),
        ),
      ],
    );
  }

  Widget _buildWeeklyStreakView(Map<String, bool> weeklyStreak) {
    List<String> days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: days.map((day) {
        bool hasStreak = weeklyStreak[day] ?? false;

        return Column(
          children: [
            Text(day.substring(0, 3),
                style: TextStyle(fontWeight: FontWeight.bold)),
            Icon(
              hasStreak ? Icons.check_circle : Icons.cancel,
              color: hasStreak ? Colors.green : Colors.red,
            ),
          ],
        );
      }).toList(),
    );
  }
}
