import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
                // Navigate based on the tab index
                switch (index) {
                  case 0:
                    context.go('/home');
                    break;
                  case 1:
                    context.go('/search');
                    break;
                  case 2:
                    // Create post page - implement as needed
                    break;
                  case 3:
                    // Challenge page - implement as needed
                    break;
                  case 4:
                    context.go('/profile');
                    break;
                }
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
                BottomNavigationBarItem(
                    icon: CircleAvatar(
                      backgroundColor: newindex == 4 ? Colors.white : Colors.transparent,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: newindex == 4 ? Colors.black : Colors.grey,
                      ),
                    ),
                    label: ''),
              ]);
        });
  }
}
