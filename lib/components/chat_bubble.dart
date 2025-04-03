import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatBubble({Key? key, required this.text, required this.isUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<TextSpan> textSpans = _parseText(text);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: RichText(
          text: TextSpan(
            children: textSpans,
            style: TextStyle(color: isUser ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  List<TextSpan> _parseText(String text) {
    List<TextSpan> textSpans = [];
    List<String> parts = text.split('*');

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 1) {
        // Odd parts are bold
        textSpans.add(TextSpan(
          text: parts[i],
          style: TextStyle(fontWeight: FontWeight.bold),
        ));
      } else {
        // Even parts are normal
        textSpans.add(TextSpan(text: parts[i]));
      }
    }

    return textSpans;
  }
}
