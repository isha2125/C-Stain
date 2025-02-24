import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
