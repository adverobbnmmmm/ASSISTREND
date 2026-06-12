import 'package:flutter/material.dart';

enum SparkFlowStage { guidelines, conditions, pool }

class SparkFlowHeader extends StatelessWidget {
  final SparkFlowStage stage;

  const SparkFlowHeader({Key? key, required this.stage}) : super(key: key);

  bool get _showTopCenterCheck => stage == SparkFlowStage.guidelines;
  bool get _showVerticalCheck =>
      stage == SparkFlowStage.conditions || stage == SparkFlowStage.pool;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                _headerRow(),
                const SizedBox(height: 16),
                _subRow(),
              ],
            ),
          ),
          Positioned(
            top: 58,
            left: MediaQuery.of(context).size.width * 0.67,
            child: const _VerticalDottedLine(height: 26),
          ),
          if (_showVerticalCheck)
            Positioned(
              top: 71,
              left: MediaQuery.of(context).size.width * 0.665,
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF16DA59),
                size: 18,
              ),
            ),
          if (_showTopCenterCheck)
            Positioned(
              top: 20,
              left: MediaQuery.of(context).size.width * 0.48,
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF16DA59),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _headerRow() {
    return Row(
      children: [
        const Expanded(
          child: _StepChip(
            title: 'Guidelines',
            icon: Icons.menu_book_outlined,
          ),
        ),
        const SizedBox(width: 8),
        const SizedBox(width: 32, child: _HorizontalDottedLine()),
        const SizedBox(width: 8),
        const Expanded(
          child: _StepChip(
            title: 'Conditions',
            icon: Icons.receipt_long_outlined,
          ),
        ),
      ],
    );
  }

  Widget _subRow() {
    return Row(
      children: [
        const Expanded(
          child: _StepChip(
            title: 'Room',
            icon: Icons.meeting_room_outlined,
          ),
        ),
        const SizedBox(width: 8),
        const SizedBox(width: 32, child: _HorizontalDottedLine()),
        const SizedBox(width: 8),
        Expanded(
          child: _StepChip(
            title: 'Pool',
            icon: Icons.pool_outlined,
            isActive: stage == SparkFlowStage.pool,
          ),
        ),
      ],
    );
  }
}

class _StepChip extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isActive;

  const _StepChip({
    required this.title,
    required this.icon,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isActive ? Colors.white54 : Colors.white30,
          width: 1.3,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalDottedLine extends StatelessWidget {
  const _HorizontalDottedLine();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        7,
        (_) => Container(
          width: 3,
          height: 3,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: Colors.white30,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _VerticalDottedLine extends StatelessWidget {
  final double height;

  const _VerticalDottedLine({required this.height});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        (height / 4).floor(),
        (_) => Container(
          width: 3,
          height: 3,
          margin: const EdgeInsets.symmetric(vertical: 1),
          decoration: BoxDecoration(
            color: Colors.white30,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
