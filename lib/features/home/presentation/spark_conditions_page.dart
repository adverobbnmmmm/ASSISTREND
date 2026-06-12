import 'package:flutter/material.dart';
import 'spark_flow_header.dart';
import 'spark_pool_page.dart';

class SparkConditionsPage extends StatefulWidget {
  final String displayName;

  const SparkConditionsPage({Key? key, this.displayName = 'User'}) : super(key: key);

  @override
  State<SparkConditionsPage> createState() => _SparkConditionsPageState();
}

class _SparkConditionsPageState extends State<SparkConditionsPage> {
  final Set<String> _selectedOptions = <String>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12161C),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SparkFlowHeader(stage: SparkFlowStage.conditions),
              const SizedBox(height: 24),
              const Text(
                'Condition',
                style: TextStyle(
                  fontSize: 42,
                  color: Color(0xFF0A59FF),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Show my name/Anonymous',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 70),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _ConditionChip(
                    label: '#Single',
                    selected: _selectedOptions.contains('#Single'),
                    onTap: () => _toggleOption('#Single'),
                  ),
                  _ConditionChip(
                    label: '#Anonymous',
                    selected: _selectedOptions.contains('#Anonymous'),
                    onTap: () => _toggleOption('#Anonymous'),
                  ),
                  _ConditionChip(
                    label: '#Multiple',
                    selected: _selectedOptions.contains('#Multiple'),
                    onTap: () => _toggleOption('#Multiple'),
                  ),
                  _ConditionChip(
                    label: '#Open',
                    selected: _selectedOptions.contains('#Open'),
                    onTap: () => _toggleOption('#Open'),
                  ),
                ],
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 122,
                  height: 58,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D5EFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SparkPoolPage(
                            displayName: widget.displayName,
                            selectedOptions: _selectedOptions.toList(),
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Ok',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleOption(String value) {
    setState(() {
      if (_selectedOptions.contains(value)) {
        _selectedOptions.remove(value);
      } else {
        _selectedOptions.add(value);
      }
    });
  }
}

class _ConditionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ConditionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: (MediaQuery.of(context).size.width - 48) / 2,
        height: 58,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1D5EFF).withOpacity(0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: selected ? const Color(0xFF1D5EFF) : Colors.white24,
            width: 1.4,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white30,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
