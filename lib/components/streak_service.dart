import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

List<DateTime> getCurrentWeekDates(DateTime today) {
  // Find the current day of the week (Sunday = 0, Monday = 1, ..., Saturday = 6)
  int currentDayOfWeek = today.weekday;

  // Find the difference between today and the last Sunday
  int differenceToSunday = currentDayOfWeek % 7;

  // Calculate the date for the last Sunday
  DateTime sunday = today.subtract(Duration(days: differenceToSunday));

  // Create a list of 7 dates from Sunday to Saturday
  List<DateTime> weekDates =
      List.generate(7, (index) => sunday.add(Duration(days: index)));

  return weekDates;
}

final weeklyStreakProvider = StreamProvider<Map<String, bool>>(
  (ref) {
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
        .map(
      (userDoc) {
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
      },
    );
  },
);
final streakProvider = StreamProvider<int>((ref) async* {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    yield 0;
    return;
  }

  final userId = user.uid;

  final userDoc = FirebaseFirestore.instance.collection('user').doc(userId);

  // Listen for real-time updates in Firestore
  await for (final snapshot in userDoc.snapshots()) {
    if (snapshot.exists) {
      final data = snapshot.data();
      final streak = data?['currentStreak'] ?? 0;
      final lastActionDateTimestamp = data?['lastActivityDate'] as Timestamp?;
      final lastActionDate = lastActionDateTimestamp?.toDate();

      DateTime today = DateTime.now();

      if (lastActionDate != null) {
        // Calculate the difference in days between today and the last action date
        final differenceInDays = today.difference(lastActionDate).inDays;

        if (differenceInDays > 1) {
          // If more than 1 day has passed without logging an action, reset the streak
          await userDoc.update({
            'currentStreak': 0,
            'lastActivityDate': today,
          });
          yield 0;
        } else {
          // If today is the next day, continue the streak
          yield streak;
        }
      } else {
        // If no last action date exists, assume the streak is 0
        yield 0;
      }
    } else {
      yield 0;
    }
  }
});

class StreakWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStreak = ref.watch(streakProvider);
    final weeklyStreakAsync = ref.watch(weeklyStreakProvider);

    DateTime today = DateTime.now();
    List<DateTime> weekDates = getCurrentWeekDates(today);

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
    // Get the current date
    DateTime today = DateTime.now();

    // Fetch the current week's dates (Sunday to Saturday)
    List<DateTime> weekDates = getCurrentWeekDates(today);

    // List of day names
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
      children: List.generate(7, (index) {
        String day = days[index];
        DateTime date =
            weekDates[index]; // Get the corresponding date for each day

        bool hasStreak = weeklyStreak[day] ?? false;

        // Format the date as MM/DD (you can adjust this format)
        String formattedDate = "${date.month}/${date.day}";

        return Column(
          children: [
            Text(
                day.substring(
                    0, 3), // Display the day name (e.g., Sun, Mon, ...)
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(formattedDate), // Display the formatted date
            Icon(
              hasStreak ? Icons.check_circle : Icons.cancel,
              color: hasStreak ? Color(0xFF237155) : const Color(0xFFE04034),
            ),
          ],
        );
      }),
    );
  }
}

Future<void> logUserAction() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return;

  final userId = user.uid;
  final userDoc = FirebaseFirestore.instance.collection('user').doc(userId);

  final snapshot = await userDoc.get();

  if (snapshot.exists) {
    final data = snapshot.data();
    final currentStreak = data?['currentStreak'] ?? 0;
    final lastActionDateTimestamp = data?['lastActivityDate'] as Timestamp?;
    final lastActionDate = lastActionDateTimestamp?.toDate();

    DateTime today = DateTime.now();

    if (lastActionDate != null) {
      final differenceInDays = today.difference(lastActionDate).inDays;

      if (differenceInDays == 1) {
        // Continue the streak if the action was logged on the next day
        await userDoc.update({
          'currentStreak': currentStreak + 1,
          'lastActivityDate': today,
        });
      } else if (differenceInDays > 1) {
        // Reset the streak if more than 1 day has passed
        await userDoc.update({
          'currentStreak': 1, // Reset to 1 because the user is logging today
          'lastActivityDate': today,
        });
      }
    } else {
      // If no previous action exists, initialize the streak
      await userDoc.set({
        'currentStreak': 1,
        'lastActivityDate': today,
      });
    }
  } else {
    // Create the document for the user if it doesn't exist
    await userDoc.set({
      'currentStreak': 1,
      'lastActivityDate': DateTime.now(),
    });
  }
}
