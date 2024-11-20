import 'package:assistrend/presentation/home/homepage.dart';
import 'package:assistrend/presentation/home/messenger.dart';
import 'package:flutter/material.dart';

import 'bottomnav.dart';

class MainPage extends StatelessWidget {
  MainPage({super.key});
  final List list = [const HomePage(), const Messenger()];

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
