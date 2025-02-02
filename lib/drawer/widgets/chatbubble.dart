import 'package:flutter/material.dart';

class Chatbubble extends StatelessWidget {
  const Chatbubble(
      {super.key, required this.message, required this.isSentByME});
  final String message;
  final bool isSentByME;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSentByME ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        child: Text(
          message,
          style: TextStyle(color: isSentByME ? Colors.white : Colors.white),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.all(12.0),
        constraints: const BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
            border: Border.all(
                color: isSentByME ? Colors.redAccent : Colors.blueAccent),
            color: isSentByME ? Colors.black : Colors.black,
            borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft:
                    isSentByME ? const Radius.circular(12) : Radius.zero,
                bottomRight:
                    isSentByME ? const Radius.circular(12) : Radius.zero)),
      ),
    );
  }
}
