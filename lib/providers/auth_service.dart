import 'package:cstain/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Provider to listen to the authentication state
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});
// here it is if u need the user id of the logged in user!!
final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null) {
    _fetchUserData();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _fetchUserData() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('user').doc(firebaseUser.uid).get();
      if (userDoc.exists) {
        state = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      }
    }
  }

  Future<void> setUser(UserModel user) async {
    state = user;
  }

  Future<void> logout() async {
    await _auth.signOut();
    state = null;
  }
}
