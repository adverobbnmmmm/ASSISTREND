import 'package:flutter/material.dart';

import 'playbutton.dart';
import 'postbottombar.dart';
import 'postheadbar.dart';

class AppPosts extends StatelessWidget {
  const AppPosts({super.key, required this.img});
  final String img;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 0,
        maxHeight: double.infinity,
      ),
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(color: Colors.blueGrey[700] ?? Colors.blueGrey),
            bottom: BorderSide(color: Colors.blueGrey[700] ?? Colors.blueGrey),
            left: BorderSide.none,
            right: BorderSide.none),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const PostHeadBar(),
          if (img != "")
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Image.network(
                img,
                fit: BoxFit.cover,
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          const Playbutton(),
          const PostBottomBar(),
        ],
      ),
    );
  }
}
