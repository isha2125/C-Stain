import 'package:cstain/screens/chatbot_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cstain/providers/chatbot_notifier.dart';

class GlobalChatbotFAB extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = ref.watch(chatbotFABVisibilityProvider);

    if (!isVisible) {
      return SizedBox.shrink(); // Don't display if not visible
    }

    return FloatingActionButton(
      onPressed: () {
        ref.read(chatbotFABVisibilityProvider.notifier).state =
            false; //hide the fab while on the chatbot screen.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChatbotScreen(userId: FirebaseAuth.instance.currentUser!.uid),
          ),
        ).then((value) => ref
                .read(chatbotFABVisibilityProvider.notifier)
                .state =
            true); //makes the fab visible again once you return from the chatbot screen.
      },
      backgroundColor: Color.fromARGB(255, 191, 238, 221),
      child: Icon(Icons.chat), // Light green color
    );
  }
}
