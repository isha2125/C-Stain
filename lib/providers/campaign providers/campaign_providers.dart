import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/models/campaigns.dart';
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
// final ParticipantUsernameProvider =
//     FutureProvider.family<String?, String>((ref, userId) async {
//   final doc =
//       await FirebaseFirestore.instance.collection('user').doc(userId).get();

//   // Ensure the document exists and has data
//   if (doc.exists && doc.data() != null) {
//     final data = doc.data() as Map<String, dynamic>;
//     return data['username'] as String? ?? "Unknown User";
//   }
//   return "Unknown User";
// });

final participantUserDataProvider =
    FutureProvider.family<Map<String, String?>, String>((ref, userId) async {
  final doc =
      await FirebaseFirestore.instance.collection('user').doc(userId).get();

  if (doc.exists && doc.data() != null) {
    final data = doc.data() as Map<String, dynamic>;
    return {
      'username': data['username'] as String? ?? "Unknown User",
      'profilePicture': data['profile_picture_url'] as String? ?? "",
    };
  }
  return {'username': "Unknown User", 'profilePicture': ""};
});

//fetches campaign details on the user campaign detail screen
final campaignStreamProvider =
    StreamProvider.family<Campaign, String>((ref, campaignId) {
  return FirebaseFirestore.instance
      .collection('campaigns')
      .doc(campaignId)
      .snapshots()
      .map((doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception("Campaign data not found for id: $campaignId");
    }
    return Campaign.fromMap(data);
  });
});

// Provider that fetches the corporate user's name by corpUserId.
// If not found in 'corporateUsers', it falls back to the 'users' collection.
final corpUserNameProvider =
    FutureProvider.family<String, String>((ref, corpUserId) async {
  final corporateDoc = await FirebaseFirestore.instance
      .collection('corporateUsers')
      .doc(corpUserId)
      .get();

  if (corporateDoc.exists) {
    final data = corporateDoc.data();
    return data?['name'] ?? 'Unnamed Corporate';
  } else {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(corpUserId)
        .get();
    if (userDoc.exists) {
      final data = userDoc.data();
      return data?['username'] ?? 'Unnamed User';
    }
  }
  return 'Unknown User';
});
