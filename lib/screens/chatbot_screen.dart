// import 'package:cstain/components/chat_bubble.dart';
// import 'package:cstain/providers/chatbot_notifier.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class ChatbotScreen extends ConsumerStatefulWidget {
//   final String userId;
//   const ChatbotScreen({required this.userId, Key? key}) : super(key: key);

//   @override
//   _ChatbotScreenState createState() => _ChatbotScreenState();
// }

// class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
//   final TextEditingController _controller = TextEditingController();

//   void _sendMessage() {
//     String query = _controller.text.trim();
//     if (query.isNotEmpty) {
//       ref.read(chatbotProvider.notifier).processUserQuery(widget.userId, query);
//       _controller.clear();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final chatMessages = ref.watch(chatbotProvider);

//     return Scaffold(
//       appBar: AppBar(title: Text("C-Stain Chatbot")),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               padding: EdgeInsets.all(8),
//               itemCount: chatMessages.length,
//               itemBuilder: (context, index) {
//                 final message = chatMessages[index];
//                 final isUser = message.containsKey('user');
//                 return ChatBubble(
//                     text: isUser ? message['user']! : message['bot']!,
//                     isUser: isUser);
//               },
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.all(8),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: InputDecoration(
//                       labelText: "Ask something...",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//*************** Fixing onscreen keyboard ***************** */
import 'dart:async';

import 'package:cstain/components/chat_bubble.dart';
import 'package:cstain/providers/chatbot_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  final String userId;
  const ChatbotScreen({required this.userId, Key? key}) : super(key: key);

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode(); // Add FocusNode

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(Duration(milliseconds: 100), () {
        // Add a delay
        FocusScope.of(context).requestFocus(_textFieldFocusNode);
      });
    });
  }

  @override
  void dispose() {
    _textFieldFocusNode.dispose(); // Dispose FocusNode
    super.dispose();
  }

  void _sendMessage() {
    String query = _controller.text.trim();
    if (query.isNotEmpty) {
      ref.read(chatbotProvider.notifier).processUserQuery(widget.userId, query);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatMessages = ref.watch(chatbotProvider);

    return Scaffold(
      appBar: AppBar(title: Text("C-Stain Chatbot")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                final message = chatMessages[index];
                final isUser = message.containsKey('user');
                return ChatBubble(
                    text: isUser ? message['user']! : message['bot']!,
                    isUser: isUser);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(_textFieldFocusNode);
                    },
                    child: TextField(
                      controller: _controller,
                      focusNode: _textFieldFocusNode, // Assign FocusNode
                      decoration: InputDecoration(
                        labelText: "Ask something...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
