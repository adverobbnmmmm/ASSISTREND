import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ListtileDrawer extends StatelessWidget {
  const ListtileDrawer({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return ListTile(  leading: const CircleAvatar(backgroundImage: NetworkImage("url"),),
      title: Text(
        title,
        style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
