import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/backend/auth_gate.dart';
import 'package:cstain/backend/firebase_options.dart';
import 'package:cstain/components/loader.dart';
import 'package:cstain/providers/auth_service.dart';
import 'package:cstain/screens/Corp%20screens/corp_bottom_nav.dart';
import 'package:cstain/screens/User%20screens/main_navigation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'C:STAIN',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFABD5C5)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: authState.when(
        data: (user) {
          if (user != null) {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('user')
                  .doc(user.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    body: Center(child: Loader()),
                  );
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    !snapshot.data!.exists) {
                  return UserAuthPage(); // If user data is missing, go to login
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final String role = userData['role'] ?? 'user';

                return role == 'corp' ? CorpBottomNav() : UserBottomNav();
              },
            );
          } else {
            return UserAuthPage(); // If no user is logged in, show login screen
          }
        },
        loading: () => Scaffold(
          body: Center(child: Loader()),
        ),
        error: (err, stack) => Scaffold(
          body: Center(child: Text('Error: ${err.toString()}')),
        ),
      ),
    );
  }
}
