import 'package:flutter/material.dart';
import 'spark_flow_header.dart';

class SparkPoolPage extends StatelessWidget {
  final String displayName;
  final List<String> selectedOptions;

  const SparkPoolPage({
    Key? key,
    this.displayName = 'User',
    this.selectedOptions = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final matches = _buildMatches(isAnonymous: selectedOptions.contains('#Anonymous'));
    final headingName = displayName.isEmpty ? 'User' : displayName;
    final ink = const Color(0xFF252A6D);

    return Scaffold(
      backgroundColor: const Color(0xFF12161C),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SparkFlowHeader(stage: SparkFlowStage.pool),
              const SizedBox(height: 6),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x30000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: ink,
                        fontSize: 28,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '#$headingName\'s Selected topics:',
                            style: TextStyle(
                              color: ink,
                              fontSize: 32,
                              height: 1.2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _TopicHandSection(
                            title: 'Cosmology',
                            names: matches['Cosmology']!,
                            ink: ink,
                          ),
                          const SizedBox(height: 24),
                          _TopicHandSection(
                            title: 'Flutter',
                            names: matches['Flutter']!,
                            ink: ink,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, List<String>> _buildMatches({required bool isAnonymous}) {
    if (isAnonymous) {
      return {
        'Cosmology': ['Anonymous 1'],
        'Flutter': ['Anonymous 2', 'Anonymous 3'],
      };
    }

    return {
      'Cosmology': ['Ashwin'],
      'Flutter': ['Jefin', 'Jen'],
    };
  }
}

class _TopicHandSection extends StatelessWidget {
  final String title;
  final List<String> names;
  final Color ink;

  const _TopicHandSection({
    required this.title,
    required this.names,
    required this.ink,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '•',
              style: TextStyle(
                color: ink,
                fontSize: 34,
                height: 1,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                color: ink,
                fontSize: 32,
                height: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (names.length == 1)
          Padding(
            padding: const EdgeInsets.only(left: 54),
            child: Text(
              '└ ${names.first}',
              style: TextStyle(
                color: ink,
                fontSize: 32,
                height: 1.2,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(left: 54),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⎧ ${names[0]}',
                  style: TextStyle(
                    color: ink,
                    fontSize: 32,
                    height: 1.2,
                  ),
                ),
                if (names.length > 1)
                  Text(
                    '⎩ ${names[1]}',
                    style: TextStyle(
                      color: ink,
                      fontSize: 32,
                      height: 1.2,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
