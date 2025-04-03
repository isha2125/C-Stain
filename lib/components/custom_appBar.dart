import 'package:cstain/providers/auth_service.dart';
import 'package:cstain/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Provider to fetch user's profile image URL
final userProfileProvider = FutureProvider.autoDispose<String?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.uid;

  if (userId == null) return null;

  try {
    final userDoc =
        await FirebaseFirestore.instance.collection('user').doc(userId).get();
    final userData = userDoc.data() as Map<String, dynamic>?;
    return userData?['profile_picture_url']; // Return profile image URL or null
  } catch (e) {
    print('Error fetching profile image: $e');
    return null; // Ensure fallback if fetching fails
  }
});

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String? title; // Title is now optional

  const CustomAppBar({Key? key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userId = authState.value?.uid;
    final profileImageAsync = ref.watch(userProfileProvider);

    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            )
          : null, // No title if it's null
      leading: Image.asset('assets/Earth black 1.png'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: userId == null
              ? IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No user logged in')),
                    );
                  },
                )
              : GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MYProfileScreen(profileUserId: userId),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade300, // Default background
                    backgroundImage: profileImageAsync.when(
                      data: (imageUrl) =>
                          imageUrl != null ? NetworkImage(imageUrl) : null,
                      loading: () => null, // No image during loading
                      error: (_, __) => null, // No image on error
                    ),
                    child: profileImageAsync.when(
                      data: (imageUrl) => imageUrl == null
                          ? const Icon(Icons.person, color: Colors.white)
                          : null, // Show icon only if image is null
                      loading: () =>
                          const CircularProgressIndicator(strokeWidth: 2),
                      error: (_, __) =>
                          const Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ),
        ),
      ],
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
