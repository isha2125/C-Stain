import 'package:cstain/backend/auth_gate.dart';
import 'package:cstain/backend/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFABD5C5)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}


// /*******************************************/
// import 'package:cstain/backend/auth_gate.dart';
// import 'package:cstain/backend/firebase_options.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   runApp(
//     ProviderScope(child: MyApp()),
//   );
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//     _initDynamicLinks();
//   }

//   // Initialize dynamic links and handle incoming links
//   Future<void> _initDynamicLinks() async {
//     FirebaseDynamicLinks.instance.onLink(
//       onSuccess: (PendingDynamicLinkData? dynamicLinkData) async {
//         final Uri? deepLink = dynamicLinkData?.link;

//         if (deepLink != null) {
//           _handleDeepLink(deepLink);
//         }
//       },
//       onError: (OnLinkErrorException e) async {
//         print('Error handling dynamic link: ${e.message}');
//       },
//     );

//     // Handle dynamic links when the app is opened from terminated state
//     final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
//     if (initialLink?.link != null) {
//       _handleDeepLink(initialLink!.link!);
//     }
//   }

//   // Function to handle the deep link and navigate accordingly
//   void _handleDeepLink(Uri deepLink) {
//     // Example: Navigate to a specific page if post ID is available in the link
//     final postId = deepLink.queryParameters['id'];
//     if (postId != null) {
//       // Navigate to the specific post page using postId
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => PostDetailPage(postId: postId), // Assume this is the page you want to navigate to
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'MyApp',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFABD5C5)),
//         useMaterial3: true,
//       ),
//       debugShowCheckedModeBanner: false,
//       home: const AuthGate(),
//     );
//   }
// }

