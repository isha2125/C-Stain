import 'package:cstain/backend/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cstain/providers/auth_service.dart'; // Import user provider

Future<void> signOut(BuildContext context, WidgetRef ref) async {
  try {
    // Show a loading dialog while signing out
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from closing manually
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Perform sign out
    await ref.read(userProvider.notifier).logout();
    await GoogleSignIn().signOut();

    // Dismiss the loading dialog before navigating
    if (context.mounted) {
      Navigator.of(context).pop(); // Close the loader dialog

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Signed out successfully"),
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate safely after sign out
      Future.microtask(() {
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => UserAuthPage()),
            (route) => false, // Clears all previous routes
          );
        }
      });
    }
  } catch (e) {
    if (context.mounted) {
      Navigator.of(context).pop(); // Close the loader in case of an error

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign out failed: ${e.toString()}")),
      );
    }
  }
}
