import 'package:flutter/material.dart';

class EventGuidelinesPage extends StatelessWidget {
  const EventGuidelinesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A20),
        elevation: 0,
        title: const Text('Event', style: TextStyle(color: Colors.white)),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _EventButton(title: 'Guidelines', icon: Icons.menu_book, selected: true),
                _EventConnector(),
                _EventButton(title: 'Conditions', icon: Icons.article_outlined),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _EventButton(title: 'Room', icon: Icons.meeting_room_outlined),
                _EventConnector(),
                _EventButton(title: 'Pool', icon: Icons.pool_outlined),
              ],
            ),
            const SizedBox(height: 30),
            const Text('Guidelines', style: TextStyle(fontSize: 20, color: Color(0xFF2972FF), fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
              '"✨ Networking is crucial for expanding opportunities, accessing valuable information, and building supportive relationships for personal and professional growth!"\n\n'
              '🚀 Here, we aim to enhance the potential of networking.\n'
              '📍 It is your secret weapon to unlock amazing opportunities, find cool jobs, and build a strong support system in this vibrant world.\n\n'
              'With your daily life AI companion, Assistrend, you can explore the world! Are you ready to begin? Click OK.',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const Spacer(),
            Center(
              child: SizedBox(
                width: 100,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2972FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text('Ok', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _EventButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  const _EventButton({required this.title, required this.icon, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? Colors.white.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _EventConnector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      child: Center(
        child: Icon(Icons.check_circle, color: Color(0xFF2972FF), size: 18),
      ),
    );
  }
}
