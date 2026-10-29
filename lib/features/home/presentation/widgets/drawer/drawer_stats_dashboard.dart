import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:popupgame/features/home/presentation/controllers/home_controller.dart';

// ==================== DRAWER STATS DASHBOARD WIDGET ====================
class DrawerStatsDashboard extends StatelessWidget {
  final HomeController controller;

  const DrawerStatsDashboard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    const Color cardBg = Color(0xFF181F46);
    const Color subtitleColor = Color(0xFF8E9CB8);
    const Color goldenYellow = Color(0xFFFFD043);
    const Color neonTeal = Color(0xFF1DBEAA);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PLAYER DASHBOARD',
          style: TextStyle(
            color: subtitleColor,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF152646), Color(0xFF162A48)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: neonTeal.withValues(alpha: 0.4), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: neonTeal.withValues(alpha: 0.12),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: neonTeal.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          color: neonTeal,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'HIGHEST LEVEL',
                        style: TextStyle(
                          color: Color(0xFF7FA2CE),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Level ${controller.unlockedLevel.value}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF282544), Color(0xFF24223E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: goldenYellow.withValues(alpha: 0.4), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: goldenYellow.withValues(alpha: 0.12),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: goldenYellow.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.star_rounded,
                          color: goldenYellow,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'STARS EARNED',
                        style: TextStyle(
                          color: Color(0xFFC7B174),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${controller.totalStars.value} / 30 ★',
                        style: const TextStyle(
                          color: goldenYellow,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Obx(() {
          final double completionRatio = (controller.totalStars.value / 30.0).clamp(0.0, 1.0);
          final int percent = (completionRatio * 100).toInt();

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF253062), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Overall Completion',
                      style: TextStyle(
                        color: Color(0xFFA5B8E0),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        color: goldenYellow,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: 8,
                    width: double.infinity,
                    color: const Color(0xFF0F1430),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: completionRatio,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFFD043), Color(0xFFFF9E1B)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
