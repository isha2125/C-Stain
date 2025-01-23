// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cstain/backend/corp_auth_page.dart';
// import 'package:cstain/components/loader.dart';
// //import 'package:cstain/components/streak_service.dart';
// import 'package:cstain/models/user.dart';
// import 'package:cstain/providers/auth_service.dart';
// import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
// import 'package:firebase_ui_auth/firebase_ui_auth.dart';
// import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../screens/main_navigation.dart';

// final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// CollectionReference get _usersCollection => _firestore.collection('user');
// final userProvider = StateProvider<UserModel?>((ref) => null);

// final userDataLoadingProvider = FutureProvider.autoDispose((ref) async {
//   final authState = await ref.watch(authStateProvider.future);
//   if (authState != null) {
//     String role = 'user'; // Initialize role with a default value
//     await AuthGate._handleUserModel(authState, ref);
//   }
// });

// class AuthGate extends ConsumerWidget {
//   const AuthGate({super.key});

//   static Future<void> _handleUserModel(User user, Ref ref) async {
//     final userDoc = await _usersCollection.doc(user.uid).get();

//     //streak provider

//     // final streakService = StreakService();

//     UserModel userModel;

//     if (!userDoc.exists) {
//       userModel = UserModel(
//         uid: user.uid,
//         bio: '',
//         created_at: Timestamp.now(),
//         email: user.email ?? 'No Email',
//         full_name: user.displayName ?? 'Climate Action Enthusiast',
//         profile_picture_url: user.photoURL ?? 'Default Profile Picture URL',
//         total_CO2_saved: 0.0,
//         username: user.displayName ?? 'No Username',
//         currentStreak: 0,
//         lastActivityDate: Timestamp.now(),
//         streak_sunday: false,
//         streak_monday: false,
//         streak_tuesday: false,
//         streak_wednesday: false,
//         streak_thursday: false,
//         streak_friday: false,
//         streak_saturday: false,
//       );

//       await _usersCollection.doc(userModel.uid).set(userModel.toMap());
//     } else {
//       userModel = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
//     }
//     //await streakService.updateStreakOnNewLog();

//     ref.read(userProvider.notifier).state = userModel;
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authStateProvider);

//     return authState.when(
//       data: (user) {
//         if (user == null) {
//           return SignInScreen(
//             providers: [
//               EmailAuthProvider(),
//               GoogleProvider(
//                 clientId:
//                     '341493656655-a49svge8kfg4jdcve8te8pg60odtep9b.apps.googleusercontent.com',
//               ),
//             ],
//             headerBuilder: (context, constraints, shrinkOffset) {
//               return Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: AspectRatio(
//                   aspectRatio: 1,
//                   child: Image.asset('assets/Earth black 1.png'),
//                 ),
//               );
//             },
//             subtitleBuilder: (context, action) {
//               return Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: action == AuthAction.signIn
//                     ? const Text('Welcome to C:Stain, please sign in!')
//                     : const Text('Welcome to C:stain, please sign up!'),
//               );
//             },
//             footerBuilder: (context, action) {
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Padding(
//                     padding: EdgeInsets.only(top: 16),
//                     child: Text(
//                       'By signing in, you agree to our terms and conditions.',
//                       style: TextStyle(color: Colors.grey),
//                       textAlign: TextAlign.left,
//                     ),
//                   ),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Text("Are you a corporate user?"),
//                       TextButton(
//                         onPressed: () {
//                           // Navigate to the corporate sign-up page
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                                 builder: (context) => const CorpAuthPage()),
//                           );
//                         },
//                         child: Text(
//                           'Sign up here',
//                           style: TextStyle(
//                               color: Color(0xFF237155),
//                               fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               );
//             },
//             sideBuilder: (context, shrinkOffset) {
//               return Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: AspectRatio(
//                   aspectRatio: 1,
//                   child: Image.asset('assets/Earth black 1.png'),
//                 ),
//               );
//             },
//           );
//         }

//         // Watch the userDataLoadingProvider
//         final userDataLoading = ref.watch(userDataLoadingProvider);

//         return userDataLoading.when(
//           data: (_) => const BottomNavigation(),
//           loading: () => const Loader(),
//           error: (error, stack) =>
//               Center(child: Text('Error loading user data')),
//         );
//       },
//       loading: () => Loader(),
//       error: (error, stack) => Center(child: Text('Something went wrong')),
//     );
//   }
// }
//***************the below codes works grt ****************************************************************************
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/backend/corp_auth_page.dart';
import 'package:cstain/components/loader.dart';
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
final userProvider = StateProvider<UserModel?>((ref) => null);

final userDataLoadingProvider = FutureProvider.autoDispose((ref) async {
  final authState = await ref.watch(authStateProvider.future);
  if (authState != null) {
    await AuthGate._handleUserModel(authState, ref);
  }
});

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  static Future<void> _handleUserModel(User user, Ref ref) async {
    final userDoc = await _usersCollection.doc(user.uid).get();

    UserModel userModel;

    if (!userDoc.exists) {
      userModel = UserModel(
        uid: user.uid,
        bio: '',
        created_at: Timestamp.now(),
        email: user.email ?? 'No Email',
        full_name: user.displayName ?? 'Climate Action Enthusiast',
        profile_picture_url: user.photoURL ?? 'Default Profile Picture URL',
        total_CO2_saved: 0.0,
        username: user.displayName ?? 'No Username',
        currentStreak: 0,
        lastActivityDate: Timestamp.now(),
        streak_sunday: false,
        streak_monday: false,
        streak_tuesday: false,
        streak_wednesday: false,
        streak_thursday: false,
        streak_friday: false,
        streak_saturday: false,
        role: 'user', // Set default role as 'user'
        // Initialize corporate fields as null since this is a regular user
      );

      await _usersCollection.doc(userModel.uid).set(userModel.toMap());
    } else {
      userModel = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
    }

    ref.read(userProvider.notifier).state = userModel;
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
                    ? const Text('Welcome to C:Stain, please sign in!')
                    : const Text('Welcome to C:stain, please sign up!'),
              );
            },
            footerBuilder: (context, action) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      'By signing in, you agree to our terms and conditions.',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Are you a corporate user?"),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => CorpAuthPage()),
                          );
                        },
                        child: Text(
                          'Sign up here',
                          style: TextStyle(
                              color: Color(0xFF237155),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
            sideBuilder: (context, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/Earth black 1.png'),
                ),
              );
            },
          );
        }

        final userDataLoading = ref.watch(userDataLoadingProvider);

        return userDataLoading.when(
          data: (_) => const BottomNavigation(),
          loading: () => const Loader(),
          error: (error, stack) =>
              Center(child: Text('Error loading user data')),
        );
      },
      loading: () => Loader(),
      error: (error, stack) => Center(child: Text('Something went wrong')),
    );
  }
}
