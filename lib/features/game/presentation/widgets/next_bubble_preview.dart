import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import 'bubble_widget.dart';

class NextBubblePreview extends StatelessWidget {
  final GameController controller;

  const NextBubblePreview({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.swapBubbles,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Obx(
                () => BubbleWidget(
                  color: controller.nextShooterColor.value,
                  size: 36,
                ),
              ),
              const Positioned(
                bottom: -2,
                right: -2,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Color(0xFFFDBB3A),
                  child: Icon(
                    Icons.swap_horiz_rounded,
                    size: 12,
                    color: Color(0xFF131938),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'SWAP',
            style: TextStyle(
              color: Color(0xFFFDBB3A),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

