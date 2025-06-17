import 'package:assistrend/presentation/home/appbar.dart';
import 'package:assistrend/presentation/home/carousel.dart';
import 'package:assistrend/presentation/home/connect.dart';
import 'package:assistrend/presentation/home/posts.dart';

import 'package:flutter/material.dart';

import 'messenger.dart';

final ValueNotifier<bool> showContainer = ValueNotifier<bool>(false);
void toggleContainer() {
  showContainer.value = !showContainer.value;
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Stack(
              children: [
                Column(children: [
                  const AppBarwidget(),
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return const CarouselSlidebar();
                        } else {
                          return const AppPosts(
                              img:
                                  "https://images.pexels.com/photos/414612/pexels-photo-414612.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500");
                        }
                      },
                      itemCount: 10,
                    ),
                  ),
                ]),
                const ConnectButton(),
                ValueListenableBuilder<bool>(
                    valueListenable: showContainer,
                    builder: (context, value, _) {
                      return Messenger(
                        isSidebaropened: showContainer.value,
                      );
                    }),
              ],
            ),
            backgroundColor: const Color(0xff181a1c)));
  }
}
