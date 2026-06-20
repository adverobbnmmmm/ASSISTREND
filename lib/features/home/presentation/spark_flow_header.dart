import 'package:flutter/material.dart';

enum SparkFlowStage { guidelines, conditions, pool }

class SparkFlowHeader extends StatelessWidget {
  final SparkFlowStage stage;

  const SparkFlowHeader({Key? key, required this.stage}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                _headerRow(),
                const SizedBox(height: 12),
                _subRow(),
              ],
            ),
          ),
          Positioned(
            top: 52,
            left: MediaQuery.of(context).size.width * 0.67,
            child: const _VerticalDottedLine(height: 26),
          ),
        ],
      ),
    );
  }

  Widget _headerRow() {
    return Row(
      children: [
        Expanded(
          child: _StepChip(
            title: 'Guidelines',
            icon: Icons.menu_book_outlined,
            isActive: stage == SparkFlowStage.guidelines,
            isDone: stage == SparkFlowStage.conditions ||
                stage == SparkFlowStage.pool,
          ),
        ),
        const SizedBox(width: 8),
        const SizedBox(width: 32, child: _HorizontalDottedLine()),
        const SizedBox(width: 8),
        Expanded(
          child: _StepChip(
            title: 'Conditions',
            icon: Icons.receipt_long_outlined,
            isActive: stage == SparkFlowStage.conditions,
            isDone: stage == SparkFlowStage.pool,
          ),
        ),
      ],
    );
  }

  Widget _subRow() {
    return Row(
      children: [
        Expanded(
          child: _StepChip(
            title: 'Room',
            icon: Icons.meeting_room_outlined,
            isActive: false,
            isDone: false,
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
            isDone: false,
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
  final bool isDone;

  const _StepChip({
    required this.title,
    required this.icon,
    this.isActive = false,
    this.isDone = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = isActive
        ? const Color(0xFF1D5EFF)
        : isDone
            ? const Color(0xFF16DA59).withOpacity(0.6)
            : Colors.white24;

    final Color bgColor = isActive
        ? const Color(0xFF1D5EFF).withOpacity(0.12)
        : isDone
            ? const Color(0xFF16DA59).withOpacity(0.07)
            : Colors.transparent;

    final Color iconColor = isActive
        ? const Color(0xFF1D5EFF)
        : isDone
            ? const Color(0xFF16DA59)
            : Colors.white54;

    final Color textColor = isActive
        ? Colors.white
        : isDone
            ? Colors.white70
            : Colors.white38;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor, width: 1.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isDone
              ? const Icon(Icons.check_circle, color: Color(0xFF16DA59), size: 18)
              : Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
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
