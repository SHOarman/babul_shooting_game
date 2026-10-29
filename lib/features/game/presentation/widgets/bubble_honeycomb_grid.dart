import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import 'bubble_widget.dart';

class BubbleHoneycombGrid extends StatelessWidget {
  final GameController controller;
  final double bubbleDiameter;

  const BubbleHoneycombGrid({
    super.key,
    required this.controller,
    required this.bubbleDiameter,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: List.generate(controller.grid.length, (r) {
          final bool isEven = r % 2 == 0;
          final double rowIndent = isEven ? 0.0 : (bubbleDiameter / 2);

          return SizedBox(
            height: bubbleDiameter * 0.86,
            child: Row(
              children: [
                if (rowIndent > 0) SizedBox(width: rowIndent),
                ...List.generate(controller.grid[r].length, (c) {
                  final item = controller.grid[r][c];
                  if (item.color == null) {
                    return SizedBox(width: bubbleDiameter, height: bubbleDiameter);
                  }
                  return SizedBox(
                    width: bubbleDiameter,
                    height: bubbleDiameter,
                    child: Center(
                      child: BubbleWidget(
                        color: item.color!,
                        size: bubbleDiameter * 0.95,
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ),
    );
  }
}

