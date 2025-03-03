import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// here are the providers for the campaign screen not for create campaign
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).currentUser;
});

final campaignsProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value([]); // Return empty list if user is not logged in
  }

  return FirebaseFirestore.instance
      .collection('campaigns')
      .where('corpUserId', isEqualTo: user.uid)
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  });
});

final categorizedCampaignsProvider =
    StreamProvider.autoDispose<Map<String, List<Map<String, dynamic>>>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value({
      'ongoing': [],
      'upcoming': [],
      'completed': [],
    });
  }

  return FirebaseFirestore.instance
      .collection('campaigns')
      .where('corpUserId', isEqualTo: user.uid)
      .orderBy('startDate', descending: false)
      .snapshots()
      .map((snapshot) {
    final now = DateTime.now();

    List<Map<String, dynamic>> ongoing = [];
    List<Map<String, dynamic>> upcoming = [];
    List<Map<String, dynamic>> completed = [];

    for (var doc in snapshot.docs) {
      final campaign = {'id': doc.id, ...doc.data()};
      final startDate = (campaign['startDate'] as Timestamp).toDate();
      final endDate = (campaign['endDate'] as Timestamp).toDate();

      if (now.isBefore(startDate)) {
        upcoming.add(campaign);
      } else if (now.isAfter(endDate)) {
        completed.add(campaign);
      } else {
        ongoing.add(campaign);
      }
    }

    return {
      'ongoing': ongoing,
      'upcoming': upcoming,
      'completed': completed,
    };
  });
});

// final campaignStateProvider =
//     StateProvider<Map<String, dynamic>?>((ref) => null);
final ParticipantUsernameProvider =
    FutureProvider.family<String?, String>((ref, userId) async {
  final doc =
      await FirebaseFirestore.instance.collection('user').doc(userId).get();

  // Ensure the document exists and has data
  if (doc.exists && doc.data() != null) {
    final data = doc.data() as Map<String, dynamic>;
    return data['username'] as String? ?? "Unknown User";
  }
  return "Unknown User";
});
