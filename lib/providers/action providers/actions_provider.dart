// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/user_contribution.dart';
// import 'auth_service.dart';
// import 'providers.dart'; // Ensure this contains the firestoreServiceProvider

// // Fetch user's today's actions provider
// final todayActionsProvider =
//     FutureProvider<List<UserContributionModel>>((ref) async {
//   final myUser = ref.watch(userProvider);
//   if (myUser == null) return [];

//   final firestoreService = ref.watch(firestoreServiceProvider);
//   return await firestoreService.fetchTodayUserContributions(myUser.uid);
// });
