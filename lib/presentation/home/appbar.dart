import 'package:flutter/material.dart';

class AppBarwidget extends StatelessWidget {
  const AppBarwidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff181a1c),
      width: double.infinity,
      height: 80,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Container(
              width: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 20),
            const Text('Good Morning, User',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(width: 20),
            Container(
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xff1f339b), width: 1),
              ),
              child: IconButton(
                  onPressed: () {},
                  icon: const Image(
                    image: AssetImage('assets/dashboard.png'),
                    color: Colors.white,
                  )),
            ),
            const SizedBox(width: 12),
            Container(
              width: 40,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xff2e4ef6)),
              child: IconButton(
                  onPressed: () {},
                  icon: const Image(
                    image: AssetImage('assets/mailbox.png'),
                    color: Colors.white,
                  )),
            )
          ],
        ),
      ),
    );
  }
}
