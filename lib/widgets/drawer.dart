import 'package:assistrendproject/Sections/sections.dart';
import 'package:flutter/material.dart';

class DrawerPage extends StatelessWidget {
  const DrawerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black,
        ),
        drawer: Drawer(backgroundColor:   Colors.black,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                      hintText: "Search Message",
                      hintStyle: const TextStyle(color: Color.fromARGB(255, 251, 249, 249)),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20))),
                ),
              ),
              const DrawerList(),
              
            ],
          ),
        ),
      ),
    );
  }
}
