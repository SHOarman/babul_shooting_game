import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';

// ==================== GAME HEADER WIDGET ====================
class GameHeader extends StatelessWidget {
  final GameController controller;

  const GameHeader({
    super.key,
    required this.controller,
  });

  void _showPauseDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF161E42),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Game Paused',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFDBB3A),
                  foregroundColor: const Color(0xFF131938),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: () => Get.back(),
                child: const Text('Resume', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF2E3966), width: 1.5),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: () {
                  Get.back();
                  controller.onInit();
                },
                child: const Text('Restart Level', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Get.back();
                  Get.back();
                },
                child: const Text(
                  'Quit to Level Menu',
                  style: TextStyle(color: Color(0xFF98A7C7), fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color buttonBg = Color(0xFF232C58);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => Get.back(),
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: buttonBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Padding(
                  padding: EdgeInsets.only(left: 6.0),
                  child: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
          Text(
            'Level ${controller.level}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: _showPauseDialog,
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: buttonBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.pause_rounded, color: Colors.white, size: 26),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
