import 'package:flutter/material.dart';

// ==================== BUBBLE COLORS & DEFINITIONS ====================
enum BubbleColor { red, yellow, teal, skyBlue, purple }

class BubbleColors {
  static const Color red = Color(0xFFFF6565);
  static const Color yellow = Color(0xFFFFD043);
  static const Color teal = Color(0xFF1DBEAA);
  static const Color skyBlue = Color(0xFF8FD7FE);
  static const Color purple = Color(0xFF8B76FF);

  static Color getColor(BubbleColor color) {
    switch (color) {
      case BubbleColor.red:
        return red;
      case BubbleColor.yellow:
        return yellow;
      case BubbleColor.teal:
        return teal;
      case BubbleColor.skyBlue:
        return skyBlue;
      case BubbleColor.purple:
        return purple;
    }
  }
}

// ==================== BUBBLE WIDGET ====================
class BubbleWidget extends StatelessWidget {
  final BubbleColor color;
  final double size;

  const BubbleWidget({
    super.key,
    required this.color,
    this.size = 38.0,
  });

  @override
  Widget build(BuildContext context) {
    final Color baseColor = BubbleColors.getColor(color);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: baseColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.35),
            blurRadius: size * 0.25,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: size * 0.16,
            left: size * 0.20,
            child: Container(
              width: size * 0.30,
              height: size * 0.30,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.70),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: size * 0.10,
            left: size * 0.14,
            child: Container(
              width: size * 0.44,
              height: size * 0.44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
