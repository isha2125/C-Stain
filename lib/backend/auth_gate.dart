import 'package:cstain/backend/corp_auth_page.dart';
import 'package:cstain/models/user.dart';
import 'package:cstain/providers/auth_service.dart';
import 'package:cstain/screens/User%20screens/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserAuthPage extends ConsumerStatefulWidget {
  @override
  _UserAuthPageState createState() => _UserAuthPageState();
}

class _UserAuthPageState extends ConsumerState<UserAuthPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true;

  Future<void> _signInWithEmail() async {
    try {
      UserCredential userCredential;
      if (_isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Create user model and save to Firestore
        UserModel newUser = UserModel(
          uid: userCredential.user!.uid,
          email: _emailController.text,
          full_name: userCredential.user!.displayName ?? "New User",
          username: userCredential.user!.email!.split('@')[0],
          bio: '',
          profile_picture_url: userCredential.user!.photoURL ?? '',
          created_at: Timestamp.now(),
          total_CO2_saved: 0.0,
          currentStreak: 0,
          lastActivityDate: Timestamp.now(),
          streak_sunday: false,
          streak_monday: false,
          streak_tuesday: false,
          streak_wednesday: false,
          streak_thursday: false,
          streak_friday: false,
          streak_saturday: false,
          role: 'user',
        );

        await _firestore
            .collection('user')
            .doc(newUser.uid)
            .set(newUser.toMap());
        ref.read(userProvider.notifier).setUser(newUser);
      }

      // Fetch user details from Firestore and update provider
      DocumentSnapshot userDoc = await _firestore
          .collection('user')
          .doc(userCredential.user!.uid)
          .get();
      UserModel loggedInUser =
          UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      ref.read(userProvider.notifier).setUser(loggedInUser);

      _navigateToUserHome();
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      DocumentSnapshot userDoc = await _firestore
          .collection('user')
          .doc(userCredential.user!.uid)
          .get();
      if (!userDoc.exists) {
        UserModel newUser = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email!,
          full_name: userCredential.user!.displayName ?? "New User",
          username: userCredential.user!.email!.split('@')[0],
          bio: '',
          profile_picture_url: userCredential.user!.photoURL ?? '',
          created_at: Timestamp.now(),
          total_CO2_saved: 0.0,
          currentStreak: 0,
          lastActivityDate: Timestamp.now(),
          streak_sunday: false,
          streak_monday: false,
          streak_tuesday: false,
          streak_wednesday: false,
          streak_thursday: false,
          streak_friday: false,
          streak_saturday: false,
          role: 'user',
        );

        await _firestore
            .collection('user')
            .doc(newUser.uid)
            .set(newUser.toMap());
        ref.read(userProvider.notifier).setUser(newUser);
      } else {
        UserModel loggedInUser =
            UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        ref.read(userProvider.notifier).setUser(loggedInUser);
      }

      _navigateToUserHome();
    } catch (e) {
      print('Google Sign-In Error: $e');
    }
  }

  void _navigateToUserHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => UserBottomNav()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'User Login' : 'User Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signInWithEmail,
              child: Text(_isLogin ? 'Login' : 'Sign Up'),
            ),
            ElevatedButton(
              onPressed: _signInWithGoogle,
              child: Text('Sign in with Google'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
              child: Text(_isLogin
                  ? "Don't have an account? Sign Up"
                  : "Already have an account? Login"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => CorpAuthPage()),
                );
              },
              child: Text("Are you a corporate user? Register here!"),
            ),
          ],
        ),
      ),
    );
  }
}
