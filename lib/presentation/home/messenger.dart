import 'package:flutter/material.dart';

import 'searchfield.dart';

class Messenger extends StatelessWidget {
  const Messenger({super.key});
  final bool isSidebaropened = false;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 150, 0, 0),
        child: Container(
            width: (MediaQuery.of(context).size.width) / 1.5,
            constraints: BoxConstraints(
                minHeight: (MediaQuery.of(context).size.height) / 2,
                maxHeight: double.infinity),
            color: const Color(0xFF282A2D),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(10, 30, 10, 10),
                  child: SearchField(),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: MessageHead(),
                ),
                buddy(),
                community(),
              ],
            )),
      ),
    );
  }

  Expanded community() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Community',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
            ),
            const Divider(
              color: Colors.blue,
            ),
            Expanded(
                child: ListView.separated(
              separatorBuilder: (context, index) {
                return const Divider(
                  color: Colors.grey,
                  thickness: 0.7,
                );
              },
              itemBuilder: (index, context) {
                return listtile('Abhijith', '');
              },
              itemCount: 3,
            )),
            Center(
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.arrow_drop_down_outlined),
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }

  Expanded buddy() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 2, 10, 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Buddy',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
            ),
            const Divider(
              color: Colors.blue,
            ),
            Expanded(
                child: ListView.separated(
              separatorBuilder: (context, index) {
                return const Divider(
                  color: Colors.grey,
                  thickness: 0.7,
                );
              },
              itemBuilder: (index, context) {
                return listtile('Abhijith', '');
              },
              itemCount: 3,
            )),
            Center(
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.arrow_drop_down_outlined),
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }

  ListTile listtile(String title, String img) {
    return ListTile(
      leading: Container(
        width: 35,
        height: 35,
        decoration: const BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
                image: AssetImage('assets/dashboard.png'), fit: BoxFit.fill),
            color: Colors.grey),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}

class MessageHead extends StatelessWidget {
  const MessageHead({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.pink,
                    Colors.purple,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Container(
                  width: 42,
                  height: 42,
                  margin: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: const Center(
                      child: Image(
                    image: AssetImage('assets/robot.png'),
                    height: 20,
                    width: 20,
                  )),
                ),
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          child: Text(
            'Assistrend',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
          ),
        )
      ],
    );
  }
}
