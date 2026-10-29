import 'package:flutter/material.dart';

class DashedDangerLine extends StatelessWidget {
  const DashedDangerLine({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double dashWidth = 8;
        const double dashSpace = 6;
        final int count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(count, (_) {
            return Container(
              width: dashWidth,
              height: 2,
              color: const Color(0xFFFF6565).withValues(alpha: 0.6),
            );
          }),
        );
      },
    );
  }
}

