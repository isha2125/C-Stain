import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/providers/corp_user_provider.dart';
import 'package:cstain/screens/Corp%20screens/corp_bottom_nav.dart';
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
  Future<void> _ChandleUserModel(User user) async {
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
        // Navigator.of(context).pushAndRemoveUntil(
        //   MaterialPageRoute(builder: (context) => CorpBottomNav()),
        //   (Route<dynamic> route) => false,
        // );
        checkCorpUser(context, ref, user.uid);
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
          await _ChandleUserModel(userCredential.user!);
          // Navigate to CorpDashboard after successful signup
          // Navigator.of(context).pushReplacement(
          //   MaterialPageRoute(builder: (context) => CorpBottomNav()),
          // );
          checkCorpUser(context, ref, userCredential.user!.uid);
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
              // Navigator.of(context).pushReplacement(
              //   MaterialPageRoute(builder: (context) => CorpBottomNav()),
              // );
              checkCorpUser(context, ref, userCredential.user!.uid);
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
      // appBar: AppBar(
      //   title: Text(
      //     _isSignUp ? 'Corporate Sign Up' : 'Corporate Sign In',
      //     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      //   ),
      //   centerTitle: true,
      //   backgroundColor: const Color(0xFF237155),
      //   elevation: 0,
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Branding Image Section
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  height: 150, // Set a smaller height for the image
                  child: Center(
                    child: Image.asset(
                      'assets/Earth black 1.png',
                      fit: BoxFit
                          .contain, // Ensures the image scales without cropping
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Text("Welcome To C:Stain, please sign up!"),
              const SizedBox(height: 20),

              // Email TextField
              _buildTextField(
                controller: _emailController,
                label: 'Corporate Email',
                hint: 'Enter your corporate email',
              ),
              const SizedBox(height: 16),

              // Password TextField
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter your password',
                obscureText: true,
              ),
              const SizedBox(height: 18),

              // Conditional Fields for Sign-Up Only
              if (_isSignUp) ...[
                _buildTextField(
                  controller: _companyNameController,
                  label: 'Company Name',
                  hint: 'Enter your company name',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _registrationNumberController,
                  label: 'Registration Number',
                  hint: 'Enter registration number',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _contactPersonController,
                  label: 'Contact Person',
                  hint: 'Enter contact person name',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _industryController,
                  label: 'Industry',
                  hint: 'Enter your industry type',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _addressController,
                  label: 'Address',
                  hint: 'Enter your company address',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _employeesController,
                  label: 'Number of Employees',
                  hint: 'Enter the number of employees',
                ),
                const SizedBox(height: 16),
              ],

              // Submit Button
              Center(
                child: SizedBox(
                  width: double.infinity, // Makes the button occupy full width
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.transparent, // Transparent background
                      foregroundColor: Colors.black, // Black text color
                      side: const BorderSide(
                          color: Colors.black, width: 1), // Black border
                      padding: const EdgeInsets.symmetric(
                          vertical: 10), // Adjust padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(50), // Rounded corners
                      ),
                      elevation: 0, // Removes shadow
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.black) // Loader in black
                        : Text(
                            _isSignUp ? 'Sign Up' : 'Sign In',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF237155)),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Google Sign-In Button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    icon: Image.asset(
                      'assets/google.png',
                      height: 24,
                    ),
                    label: const Text(
                      'Sign in with Google',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color.fromARGB(255, 43, 43, 43),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Toggle Between Sign-Up and Sign-In
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
                  style: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Helper Method to Create TextFields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey))),
      obscureText: obscureText,
      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
    );
  }
}

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
//               // Other text fields...
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
//               const SizedBox(height: 16),
//               ElevatedButton.icon(
//                 onPressed: _isLoading ? null : _signInWithGoogle,
//                 icon: Image.asset(
//                   'assets/google_logo.png',
//                   height: 24,
//                 ),
//                 label: const Text('Sign in with Google'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white,
//                   foregroundColor: Colors.black,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                 ),
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