import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/models/achievements.dart';
import 'package:cstain/models/badges.dart';
import 'package:cstain/models/categories_and_action.dart';
import 'package:cstain/models/user.dart';
import 'package:cstain/models/user_achievement.dart';
import 'package:cstain/models/user_badges.dart';
import 'package:cstain/models/user_contribution.dart';
import 'package:cstain/providers/auth_service.dart';
import 'package:cstain/providers/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoriesProvider =
    FutureProvider<List<CategoriesAndActionModel>>((ref) async {
  try {
    final repository = FirestoreService();
    final categories = await repository.fetchCategoriesAndActions();
    print('Fetched categories: $categories');
    return categories;
  } catch (e) {
    print('Error in categoriesProvider: $e');
    rethrow;
  }
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final userContributionsProvider =
    FutureProvider.family<List<UserContributionModel>, String>(
        (ref, userId) async {
  final firestoreService = ref.read(firestoreServiceProvider);
  return firestoreService.fetchTodayUserContributions(userId);
});

final userStreamProvider = StreamProvider.autoDispose<UserModel>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception('User not authenticated');
  return firestoreService.getUserStream(user.uid);
});

final badgesProvider = FutureProvider<List<BadgesModel>>((ref) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.fetchBadges();
});

final userBadgesProvider =
    StreamProvider.autoDispose<List<UserBadgesModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) throw Exception('User not authenticated');
  return ref.watch(firestoreServiceProvider).getUserBadgesStream(user.uid);
});

final latestUserAchievementProvider =
    FutureProvider.family<UserAchievementsModel?, String>((ref, userId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.fetchLatestUserAchievement(userId);
});

final userAchievementsWithDetailsProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) throw Exception('User not authenticated');
  return ref
      .watch(firestoreServiceProvider)
      .getUserAchievementsWithDetailsStream(user.uid);
});

final achievementsProvider =
    FutureProvider<List<AchievementsModel>>((ref) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final achievements = await firestoreService.fetchAchievements();
  print("Fetched ${achievements.length} achievements");
  return achievements;
});

final userContributionsStreamProvider =
    StreamProvider<List<UserContributionModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    throw Exception('User not authenticated');
  }
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUserContributionsStream(user.uid);
});

// Add these new providers at the end of the file

final filteredUserContributionsProvider =
    FutureProvider.family<List<UserContributionModel>, DateTimeRange>(
        (ref, dateRange) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) throw Exception('User not authenticated');
  final firestoreService = ref.watch(firestoreServiceProvider);
  final contributions = await firestoreService.getUserContributions(user.uid);
  return contributions
      .where((contribution) =>
          contribution.createdAtDateTime.isAfter(dateRange.start) &&
          contribution.createdAtDateTime
              .isBefore(dateRange.end.add(Duration(days: 1))))
      .toList();
});

final weeklyDataProvider =
    FutureProvider.family<Map<int, double>, DateTimeRange>(
        (ref, dateRange) async {
  final contributions =
      await ref.watch(filteredUserContributionsProvider(dateRange).future);
  final weeklyData = <int, double>{};
  for (var contribution in contributions) {
    final weekNumber =
        contribution.createdAtDateTime.difference(dateRange.start).inDays ~/ 7;
    weeklyData[weekNumber] =
        (weeklyData[weekNumber] ?? 0) + contribution.co2_saved;
  }
  return weeklyData;
});

final monthlyDataProvider =
    FutureProvider.family<Map<int, double>, DateTimeRange>(
        (ref, dateRange) async {
  final contributions =
      await ref.watch(filteredUserContributionsProvider(dateRange).future);
  final monthlyData = <int, double>{};
  for (var contribution in contributions) {
    final monthNumber =
        (contribution.createdAtDateTime.year - dateRange.start.year) * 12 +
            contribution.createdAtDateTime.month -
            dateRange.start.month;
    monthlyData[monthNumber] =
        (monthlyData[monthNumber] ?? 0) + contribution.co2_saved;
  }
  return monthlyData;
});

// In /lib/providers/providers.dart

// final co2SavedOverTimeProvider =
//     FutureProvider<List<UserContributionModel>>((ref) async {
//   final firestoreService = ref.watch(firestoreServiceProvider);
//   final user = ref.watch(userStreamProvider.asProvider()).value;
//   if (user == null) throw Exception('User not authenticated');
//   return firestoreService.getUserContributions(user.uid);
// });

// final categoryBreakdownProvider =
//     FutureProvider<Map<String, double>>((ref) async {
//   final contributions = await ref.watch(co2SavedOverTimeProvider.future);
//   final breakdown = <String, double>{};
//   for (final contribution in contributions) {
//     breakdown.update(
//         contribution.category, (value) => value + contribution.co2_saved,
//         ifAbsent: () => contribution.co2_saved);
//   }
//   return breakdown;
// });

// final dailyContributionsProvider =
//     FutureProvider<Map<DateTime, double>>((ref) async {
//   final contributions = await ref.watch(co2SavedOverTimeProvider.future);
//   final dailyContributions = <DateTime, double>{};
//   for (final contribution in contributions) {
//     final date = DateTime(
//         contribution.createdAtDateTime.year,
//         contribution.createdAtDateTime.month,
//         contribution.createdAtDateTime.day);
//     dailyContributions.update(date, (value) => value + contribution.co2_saved,
//         ifAbsent: () => contribution.co2_saved);
//   }
//   return dailyContributions;
// });

// final co2SavingsByActionProvider =
//     FutureProvider<Map<String, double>>((ref) async {
//   final contributions = await ref.watch(co2SavedOverTimeProvider.future);
//   final savingsByAction = <String, double>{};
//   for (final contribution in contributions) {
//     savingsByAction.update(
//         contribution.action, (value) => value + contribution.co2_saved,
//         ifAbsent: () => contribution.co2_saved);
//   }
//   return savingsByAction;
// });
