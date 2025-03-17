import 'package:cstain/backend/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cstain/providers/auth_service.dart'; // Import user provider

Future<void> signOut(BuildContext context, WidgetRef ref) async {
  try {
    await ref.read(userProvider.notifier).logout(); // Logout from FirebaseAuth
    await GoogleSignIn().signOut(); // Sign out from Google if used

    // Show success message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Signed out successfully"),
          duration: Duration(seconds: 2),
        ),
      );
    }

    // Delay navigation to avoid accessing a deactivated widget
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => UserAuthPage()),
          (route) => false, // Clears all previous routes
        );
      }
    });
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign out failed: ${e.toString()}")),
      );
    }
  }
}
