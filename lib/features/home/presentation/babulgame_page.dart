import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../game/presentation/controllers/game_controller.dart';
import '../../game/presentation/widgets/aim_line_painter.dart';
import '../../game/presentation/widgets/bubble_honeycomb_grid.dart';
import '../../game/presentation/widgets/bubble_widget.dart';
import '../../game/presentation/widgets/dashed_danger_line.dart';
import '../../game/presentation/widgets/game_header.dart';
import '../../game/presentation/widgets/game_stats_bar.dart';
import '../../game/presentation/widgets/next_bubble_preview.dart';
import '../../game/presentation/widgets/shooter_bubble_widget.dart';

// ==================== BUBBLE GAME PAGE ====================
class BabulgamePage extends StatefulWidget {
  const BabulgamePage({super.key});

  @override
  State<BabulgamePage> createState() => _BabulgamePageState();
}

class _BabulgamePageState extends State<BabulgamePage> {
  late final GameController controller;

  @override
  void initState() {
    super.initState();
    final int level = Get.arguments?['level'] as int? ?? 1;
    if (Get.isRegistered<GameController>()) {
      Get.delete<GameController>(force: true);
    }
    controller = Get.put(GameController(level: level));
  }

  @override
  void dispose() {
    if (Get.isRegistered<GameController>()) {
      Get.delete<GameController>(force: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF121634);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ==================== TOP HEADER ====================
            GameHeader(controller: controller),
            const SizedBox(height: 10),

            // ==================== STATS & PROGRESS BAR ====================
            GameStatsBar(controller: controller),
            const SizedBox(height: 12),

            // ==================== GAMEPLAY CANVAS ====================
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double boardWidth = constraints.maxWidth;
                  final double boardHeight = constraints.maxHeight;
                  final double bubbleDiameter = (boardWidth - 20.0) / 8.0;

                  final Offset shooterPos = Offset(
                    boardWidth / 2,
                    boardHeight - 24.0 - (bubbleDiameter / 2),
                  );

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanDown: (details) => controller.updateAim(details.localPosition),
                    onPanUpdate: (details) => controller.updateAim(details.localPosition),
                    onPanEnd: (_) => controller.shoot(shooterPos, boardWidth, boardHeight, bubbleDiameter),
                    onTapUp: (details) {
                      if (details.localPosition.dy < boardHeight - 80) {
                        controller.updateAim(details.localPosition);
                        controller.shoot(shooterPos, boardWidth, boardHeight, bubbleDiameter);
                      }
                    },
                    child: SizedBox(
                      width: boardWidth,
                      height: boardHeight,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Obx(
                            () => Positioned(
                              top: controller.gridOffsetY.value,
                              left: 10,
                              right: 10,
                              child: BubbleHoneycombGrid(
                                controller: controller,
                                bubbleDiameter: bubbleDiameter,
                              ),
                            ),
                          ),
                          Positioned(
                            top: (bubbleDiameter * 0.86 * controller.dangerRowIndex),
                            left: 0,
                            right: 0,
                            child: const DashedDangerLine(),
                          ),
                          Positioned.fill(
                            child: Obx(
                              () => CustomPaint(
                                size: Size(boardWidth, boardHeight),
                                painter: AimLinePainter(
                                  start: shooterPos,
                                  end: controller.aimPosition.value,
                                  boardWidth: boardWidth,
                                  boardHeight: boardHeight,
                                  bubbleRadius: bubbleDiameter / 2,
                                  aimColor: BubbleColors.getColor(controller.currentShooterColor.value),
                                  grid: controller.grid,
                                  gridOffsetY: controller.gridOffsetY.value,
                                ),
                              ),
                            ),
                          ),
                          Obx(() {
                            if (controller.movingBubblePosition.value != null) {
                              final pos = controller.movingBubblePosition.value!;
                              return Positioned(
                                left: pos.dx - (bubbleDiameter / 2),
                                top: pos.dy - (bubbleDiameter / 2),
                                child: BubbleWidget(
                                  color: controller.currentShooterColor.value,
                                  size: bubbleDiameter,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                          Positioned(
                            left: 24,
                            bottom: 12,
                            child: NextBubblePreview(controller: controller),
                          ),
                          Positioned(
                            left: (boardWidth / 2) - (bubbleDiameter / 2),
                            bottom: 24,
                            child: ShooterBubbleWidget(
                              controller: controller,
                              bubbleDiameter: bubbleDiameter,
                            ),
                          ),
                          Obx(() {
                            final text = controller.comboBannerText.value;
                            if (text.isEmpty) return const SizedBox.shrink();
                            return Positioned(
                              top: 20,
                              left: 20,
                              right: 20,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFFD043), Color(0xFFFF9E1B)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFFD043).withValues(alpha: 0.55),
                                        blurRadius: 16,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    text,
                                    style: const TextStyle(
                                      color: Color(0xFF131938),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
