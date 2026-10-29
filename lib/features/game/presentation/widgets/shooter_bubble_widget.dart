import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import 'bubble_widget.dart';

class ShooterBubbleWidget extends StatelessWidget {
  final GameController controller;
  final double bubbleDiameter;

  const ShooterBubbleWidget({
    super.key,
    required this.controller,
    required this.bubbleDiameter,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.swapBubbles,
      behavior: HitTestBehavior.opaque,
      child: Obx(
        () => controller.isShooting.value
            ? const SizedBox.shrink()
            : BubbleWidget(
                color: controller.currentShooterColor.value,
                size: bubbleDiameter,
              ),
      ),
    );
  }
}

