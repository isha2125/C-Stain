import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/models/user.dart';
import 'package:cstain/providers/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/main_navigation.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

CollectionReference get _usersCollection => _firestore.collection('user');

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  // Separate async function to handle Firestore write
  Future<void> _handleUserModel(User user) async {
    // Check if the user already exists in Firestore
    final userDoc = await _usersCollection.doc(user.uid).get();

    if (!userDoc.exists) {
      // The user is new, create a new instance of your user model
      UserModel userModel = UserModel(
        uid: user.uid, // Include the uid from the authenticated user
        bio:
            '', // You might need to fetch this from Firestore or another source
        created_at:
            Timestamp.now(), // Set this to a proper Timestamp if available
        email: user.email ?? 'No Email',
        full_name: user.displayName ??
            'Climate Action Enthusiast', // Handle passwords securely; this field might not be used
        profile_picture_url: user.photoURL ?? 'Default Profile Picture URL',
        total_CO2_saved: 0.0,
        username: user.displayName ??
            'No Username', // Or fetch from a different source if available
      );

      // Perform the Firestore write operation
      await _usersCollection.doc(userModel.uid).set(userModel.toMap());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
              GoogleProvider(
                clientId:
                    '341493656655-a49svge8kfg4jdcve8te8pg60odtep9b.apps.googleusercontent.com',
              ),
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/Earth black 1.png'),
                ),
              );
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ? const Text('Welcome to FlutterFire, please sign in!')
                    : const Text('Welcome to FlutterFire, please sign up!'),
              );
            },
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
            sideBuilder: (context, shrinkOffset) {
              return Padding(
                  padding: const EdgeInsets.all(20),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.asset('assets/Earth black 1.png'),
                  ));
            },
          );
        }

        // Call the async function to handle user data and Firestore write
        _handleUserModel(user);

        return const BottomNavigation();
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Center(child: Text('Something went wrong')),
    );
  }
}
