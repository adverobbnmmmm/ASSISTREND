// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import 'searchfield.dart';

class Messenger extends StatelessWidget {
  final bool isSidebaropened;
  const Messenger({super.key, required this.isSidebaropened});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isSidebaropened,
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 150, 0, 0),
          child: Container(
              width: (MediaQuery.of(context).size.width) / 1.5,
              constraints: BoxConstraints(
                  minHeight: (MediaQuery.of(context).size.height) / 1.2,
                  maxHeight: double.infinity),
              color: const Color(0xFF282A2D),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(10, 25, 10, 5),
                      child: SearchField(),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                      child: MessageHead(),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 1.5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(height: 290, child: buddy()),
                          SizedBox(height: 290, child: community()),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }

  community() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 2, 10, 0),
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
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    listtile('Abhijith', ''),
                    if (index < 2)
                      const Divider(color: Colors.grey, thickness: 0.7),
                  ],
                );
              },
            ),
          ),
          Center(
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.arrow_drop_down_outlined),
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  buddy() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 3),
      child: SizedBox(
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
            Flexible(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      listtile('Abhijith', ''),
                      if (index < 2)
                        const Divider(color: Colors.grey, thickness: 0.7),
                    ],
                  );
                },
              ),
            ),
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
