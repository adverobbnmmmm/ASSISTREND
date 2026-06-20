import 'package:flutter/material.dart';

class SparkPoolPage extends StatelessWidget {
  final String displayName;
  final List<String> selectedOptions;

  const SparkPoolPage({
    Key? key,
    this.displayName = 'User',
    this.selectedOptions = const [],
  }) : super(key: key);

  static const _blue = Color(0xFF1D5EFF);

  @override
  Widget build(BuildContext context) {
    final isAnonymous = selectedOptions.contains('#Anonymous');
    final matches = _buildMatches(isAnonymous: isAnonymous);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Spark Pool', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: matches.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.water_drop, color: _blue, size: 48),
                  SizedBox(height: 16),
                  Text('No one in the pool yet', style: TextStyle(color: Colors.white, fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Check back soon!', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: matches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final topic = matches.keys.elementAt(index);
                final names = matches[topic]!;
                return _SimpleCard(topic: topic, names: names, isAnonymous: isAnonymous);
              },
            ),
    );
  }

  Map<String, List<String>> _buildMatches({required bool isAnonymous}) {
    if (isAnonymous) return {};
    return {
      'Cosmology': ['Ashwin'],
      'Flutter': ['Jefin', 'Jen'],
      'AI & ML': ['Arjun', 'Meera', 'Rohan'],
      'Design': ['Sara'],
    };
  }
}

class _SimpleCard extends StatelessWidget {
  final String topic;
  final List<String> names;
  final bool isAnonymous;

  const _SimpleCard({required this.topic, required this.names, required this.isAnonymous});

  static const _blue = Color(0xFF1D5EFF);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(topic, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: _blue.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: Text('${names.length}', style: const TextStyle(color: _blue, fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: names.map((name) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF282A2D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [_blue, Color(0xFF6C63FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Center(child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isAnonymous ? 'Anonymous' : name,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}