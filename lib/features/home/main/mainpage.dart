import 'package:assistrend/features/home/presentation/homepage.dart';
import 'package:assistrend/features/home/presentation/messenger.dart';
import 'package:flutter/material.dart';

import 'bottomnav.dart';

class MainPage extends StatelessWidget {
  MainPage({super.key});
  final List list = [
    const HomePage(),
    const Messenger(
      isSidebaropened: true,
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: indexNotifier,
        builder: (context, int index, _) {
          return list[index];
        },
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
