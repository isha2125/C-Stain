// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/user.dart';

// class CorpAuthPage extends ConsumerStatefulWidget {
//   const CorpAuthPage({Key? key}) : super(key: key);

//   @override
//   ConsumerState<CorpAuthPage> createState() => _CorpAuthPageState();
// }

// class _CorpAuthPageState extends ConsumerState<CorpAuthPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _companyNameController = TextEditingController();
//   final _registrationNumberController = TextEditingController();
//   final _contactPersonController = TextEditingController();
//   final _industryController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _employeesController = TextEditingController();
//   bool _isLoading = false;
//   bool _isSignUp = true;

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   CollectionReference get _usersCollection => _firestore.collection('user');

//   Future<void> _handleUserModel(User user) async {
//     final userDoc = await _usersCollection.doc(user.uid).get();

//     if (!userDoc.exists) {
//       final userModel = UserModel(
//         uid: user.uid,
//         bio: '',
//         created_at: Timestamp.now(),
//         email: user.email ?? 'No Email',
//         full_name: _contactPersonController.text,
//         profile_picture_url: user.photoURL ?? 'Default Profile Picture URL',
//         total_CO2_saved: 0.0,
//         username: _companyNameController.text, // Using company name as username
//         currentStreak: 0,
//         lastActivityDate: Timestamp.now(),
//         streak_sunday: false,
//         streak_monday: false,
//         streak_tuesday: false,
//         streak_wednesday: false,
//         streak_thursday: false,
//         streak_friday: false,
//         streak_saturday: false,
//         role: 'corp', // Setting role as corporate
//       );

//       await _usersCollection.doc(userModel.uid).set(userModel.toMap());
//     }
//   }

//   Future<void> _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         UserCredential userCredential;
//         if (_isSignUp) {
//           userCredential =
//               await FirebaseAuth.instance.createUserWithEmailAndPassword(
//             email: _emailController.text,
//             password: _passwordController.text,
//           );
//           await _handleUserModel(userCredential.user!);
//         } else {
//           userCredential =
//               await FirebaseAuth.instance.signInWithEmailAndPassword(
//             email: _emailController.text,
//             password: _passwordController.text,
//           );
//           // Verify if the user is a corporate user
//           final userDoc =
//               await _usersCollection.doc(userCredential.user!.uid).get();
//           if (userDoc.exists) {
//             final userData = userDoc.data() as Map<String, dynamic>;
//             if (userData['role'] != 'corp') {
//               throw 'This account is not registered as a corporate user';
//             }
//           }
//         }

//         Navigator.of(context)
//             .pop(); // Return to previous screen after successful auth
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(e.toString())),
//         );
//       }

//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_isSignUp ? 'Corporate Sign Up' : 'Corporate Sign In'),
//         backgroundColor: const Color(0xFF237155),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 20),
//                 child: AspectRatio(
//                   aspectRatio: 2,
//                   child: Image.asset('assets/Earth black 1.png'),
//                 ),
//               ),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(
//                   labelText: 'Corporate Email',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) =>
//                     value?.isEmpty ?? true ? 'Required' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: const InputDecoration(
//                   labelText: 'Password',
//                   border: OutlineInputBorder(),
//                 ),
//                 obscureText: true,
//                 validator: (value) =>
//                     value?.isEmpty ?? true ? 'Required' : null,
//               ),
//               if (_isSignUp) ...[
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _companyNameController,
//                   decoration: const InputDecoration(
//                     labelText: 'Company Name',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) =>
//                       value?.isEmpty ?? true ? 'Required' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _registrationNumberController,
//                   decoration: const InputDecoration(
//                     labelText: 'Business Registration Number',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) =>
//                       value?.isEmpty ?? true ? 'Required' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _contactPersonController,
//                   decoration: const InputDecoration(
//                     labelText: 'Contact Person Name',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) =>
//                       value?.isEmpty ?? true ? 'Required' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _industryController,
//                   decoration: const InputDecoration(
//                     labelText: 'Industry',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) =>
//                       value?.isEmpty ?? true ? 'Required' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _employeesController,
//                   decoration: const InputDecoration(
//                     labelText: 'Number of Employees',
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) =>
//                       value?.isEmpty ?? true ? 'Required' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _addressController,
//                   decoration: const InputDecoration(
//                     labelText: 'Company Address',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) =>
//                       value?.isEmpty ?? true ? 'Required' : null,
//                 ),
//               ],
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: _isLoading ? null : _submitForm,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF237155),
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 child: _isLoading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : Text(_isSignUp ? 'Sign Up' : 'Sign In'),
//               ),
//               TextButton(
//                 onPressed: () {
//                   setState(() {
//                     _isSignUp = !_isSignUp;
//                   });
//                 },
//                 child: Text(
//                   _isSignUp
//                       ? 'Already have an account? Sign In'
//                       : 'Don\'t have an account? Sign Up',
//                   style: const TextStyle(color: Color(0xFF237155)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//****************************the below code works out grt********************************** */
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/screens/cormBottomNav.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user.dart';

class CorpAuthPage extends ConsumerStatefulWidget {
  const CorpAuthPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CorpAuthPage> createState() => _CorpAuthPageState();
}

class _CorpAuthPageState extends ConsumerState<CorpAuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _industryController = TextEditingController();
  final _addressController = TextEditingController();
  final _employeesController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = true;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  CollectionReference get _usersCollection => _firestore.collection('user');
  Future<void> _handleUserModel(User user) async {
    final userDoc = await _usersCollection.doc(user.uid).get();

    if (!userDoc.exists) {
      final userModel = UserModel(
        uid: user.uid,
        bio: '',
        created_at: Timestamp.now(),
        email: user.email ?? 'No Email',
        full_name: _contactPersonController.text.isNotEmpty
            ? _contactPersonController.text
            : 'No Name',
        profile_picture_url: user.photoURL ?? 'Default Profile Picture URL',
        total_CO2_saved: 0.0,
        username: _companyNameController.text.isNotEmpty
            ? _companyNameController.text
            : 'Default Username',
        currentStreak: 0,
        lastActivityDate: Timestamp.now(),
        streak_sunday: false,
        streak_monday: false,
        streak_tuesday: false,
        streak_wednesday: false,
        streak_thursday: false,
        streak_friday: false,
        streak_saturday: false,
        role: 'corp', // Explicitly setting the role to 'corp'
      );

      await _usersCollection.doc(userModel.uid).set(userModel.toMap());
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Google Sign-In was cancelled';
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;

      if (user != null) {
        // Check if user document exists in Firestore
        final userDoc = await _usersCollection.doc(user.uid).get();

        if (userDoc.exists) {
          // Check if role is not 'corp'
          final userData = userDoc.data() as Map<String, dynamic>;
          if (userData['role'] != 'corp') {
            // If role is not 'corp', update the role
            await _usersCollection.doc(user.uid).update({
              'role': 'corp',
            });
          }
        } else {
          // If user does not exist, create new corporate user
          final userModel = UserModel(
            uid: user.uid,
            bio: '',
            created_at: Timestamp.now(),
            email: user.email ?? 'No Email',
            full_name: googleUser.displayName ?? 'No Name',
            profile_picture_url: user.photoURL ?? 'Default Profile Picture URL',
            total_CO2_saved: 0.0,
            username: googleUser.displayName ?? 'Default Username',
            currentStreak: 0,
            lastActivityDate: Timestamp.now(),
            streak_sunday: false,
            streak_monday: false,
            streak_tuesday: false,
            streak_wednesday: false,
            streak_thursday: false,
            streak_friday: false,
            streak_saturday: false,
            role: 'corp', // Explicitly setting role as 'corp'
          );

          await _usersCollection.doc(userModel.uid).set(userModel.toMap());
        }

        // Navigate directly to CorpDashboard
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => CorpBottomNav()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential;
        if (_isSignUp) {
          // Signing up a new corporate user
          userCredential =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );
          await _handleUserModel(userCredential.user!);
          // Navigate to CorpDashboard after successful signup
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => CorpBottomNav()),
          );
        } else {
          // Signing in an existing corporate user
          userCredential =
              await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );

          // Check the role of the logged-in user
          final userDoc =
              await _usersCollection.doc(userCredential.user!.uid).get();
          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;
            if (userData['role'] == 'corp') {
              // Navigate to CorpDashboard
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => CorpBottomNav()),
              );
            } else {
              throw 'This account is not registered as a corporate user';
            }
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? 'Corporate Sign Up' : 'Corporate Sign In'),
        backgroundColor: const Color(0xFF237155),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: AspectRatio(
                  aspectRatio: 2,
                  child: Image.asset('assets/Earth black 1.png'),
                ),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Corporate Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              // Other text fields...
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF237155),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isSignUp ? 'Sign Up' : 'Sign In'),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _signInWithGoogle,
                icon: Image.asset(
                  'assets/google_logo.png',
                  height: 24,
                ),
                label: const Text('Sign in with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isSignUp = !_isSignUp;
                  });
                },
                child: Text(
                  _isSignUp
                      ? 'Already have an account? Sign In'
                      : 'Don\'t have an account? Sign Up',
                  style: const TextStyle(color: Color(0xFF237155)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//************************the sign in screen trial */
// import 'package:cstain/screens/CorpDashboard.dart';
// import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_ui_auth/firebase_ui_auth.dart';

// class CorpAuthPage extends StatelessWidget {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<void> _setUserRoleToCorp(User user) async {
//     final usersCollection = _firestore.collection('user');
//     final userDoc = await usersCollection.doc(user.uid).get();

//     if (userDoc.exists) {
//       // Check if the user role is 'corp' or not
//       final userData = userDoc.data()!;
//       if (userData['role'] != 'corp') {
//         // If role is not 'corp', update the role to 'corp'
//         await usersCollection.doc(user.uid).update({
//           'role': 'corp', // Explicitly setting the role to 'corp'
//         });
//       }
//     } else {
//       // If user doesn't exist, create a new document with role 'corp'
//       await usersCollection.doc(user.uid).set({
//         'uid': user.uid,
//         'email': user.email,
//         'role': 'corp', // Setting role explicitly as 'corp'
//         'username': user.displayName ?? 'Corporate User',
//         'created_at': Timestamp.now(),
//         'bio': '',
//         'total_CO2_saved': 0.0,
//         'currentStreak': 0,
//         'lastActivityDate': Timestamp.now(),
//         'streak_sunday': false,
//         'streak_monday': false,
//         'streak_tuesday': false,
//         'streak_wednesday': false,
//         'streak_thursday': false,
//         'streak_friday': false,
//         'streak_saturday': false,
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SignInScreen(
//       actions: [
//         AuthStateChangeAction<SignedIn>((context, state) async {
//           final user = FirebaseAuth.instance.currentUser;

//           if (user != null) {
//             // Explicitly set role to 'corp' right after sign-in
//             await _setUserRoleToCorp(user);

//             // Navigate to CorpDashboard after setting the role
//             Navigator.of(context).pushAndRemoveUntil(
//               MaterialPageRoute(builder: (context) => CorpDashboard()),
//               (route) => false,
//             );
//           }
//         }),
//       ],
//       providers: [
//         EmailAuthProvider(),
//         GoogleProvider(
//           clientId:
//               '341493656655-a49svge8kfg4jdcve8te8pg60odtep9b.apps.googleusercontent.com',
//         ),
//       ],
//       headerBuilder: (context, constraints, _) {
//         return Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             children: [
//               Image.asset('assets/Earth black 1.png', height: 100),
//               const Text(
//                 'Corporate Sign-In',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//         );
//       },
//       footerBuilder: (context, _) {
//         return const Padding(
//           padding: EdgeInsets.only(top: 16),
//           child: Text(
//             'By signing in, you agree to our Terms and Conditions.',
//             style: TextStyle(fontSize: 12, color: Colors.grey),
//             textAlign: TextAlign.center,
//           ),
//         );
//       },
//     );
//   }
// }
