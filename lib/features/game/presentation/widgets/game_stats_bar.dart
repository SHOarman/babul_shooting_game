import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';

// ==================== GAME STATS BAR ====================
class GameStatsBar extends StatelessWidget {
  final GameController controller;

  const GameStatsBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    const Color statsLabelColor = Color(0xFF8E9CB8);
    const Color barFillColor = Color(0xFFFFD043);
    const Color barTrackColor = Color(0xFF232C58);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Obx(
                () => RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Moves ',
                        style: TextStyle(
                          color: statsLabelColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: '${controller.movesRemaining.value}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Obx(() {
                final int stars = controller.currentStarsEarned.value;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final bool active = index < stars;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 300),
                        scale: active ? 1.15 : 1.0,
                        child: Icon(
                          Icons.star_rounded,
                          size: 24,
                          color: active ? const Color(0xFFFFD043) : const Color(0xFF28345C),
                        ),
                      ),
                    );
                  }),
                );
              }),
              Obx(
                () => RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Score ',
                        style: TextStyle(
                          color: statsLabelColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: '${controller.currentScore.value}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      TextSpan(
                        text: ' / ${controller.targetScore}',
                        style: const TextStyle(
                          color: statsLabelColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(
              height: 8,
              width: double.infinity,
              color: barTrackColor,
              child: Obx(() {
                final double progress = (controller.currentScore.value / controller.targetScore).clamp(0.0, 1.0);
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(color: barFillColor),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
