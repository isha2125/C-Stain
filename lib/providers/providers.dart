import 'package:cstain/models/categories_and_action.dart';
import 'package:cstain/models/user.dart';
import 'package:cstain/models/user_contribution.dart';
import 'package:cstain/providers/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
