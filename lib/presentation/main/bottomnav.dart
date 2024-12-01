import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../notification/notificationservices.dart';

ValueNotifier<int> indexNotifier = ValueNotifier<int>(0);

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({
    super.key,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onMessage.listen((message) {
      LocalNotificationService.display(message);
    });

    LocalNotificationService.storeToken();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: indexNotifier,
        builder: (context, int newindex, _) {
          return BottomNavigationBar(
              backgroundColor: Colors.black,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey,
              currentIndex: newindex,
              onTap: (index) {
                indexNotifier.value = index;
              },
              items: [
                const BottomNavigationBarItem(
                    icon: Icon(Icons.home, size: 40), label: ''),
                const BottomNavigationBarItem(
                    icon: Icon(Icons.search, size: 40), label: ''),
                BottomNavigationBarItem(
                    icon: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue, // Background color of the circle
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 30,
                      ),
                    ),
                    label: ''),
                BottomNavigationBarItem(
                    icon: Image(
                      image: const AssetImage('assets/threewaysymbol.png'),
                      height: 50,
                      width: 50,
                      color: newindex == 3 ? Colors.white : Colors.grey,
                    ),
                    label: ''),
                const BottomNavigationBarItem(
                    icon: Icon(
                      Icons.notifications_active_sharp,
                      size: 40,
                    ),
                    label: ''),
              ]);
        });
  }
}
