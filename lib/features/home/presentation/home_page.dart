import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/home_controller.dart';
import 'widgets/custom_lavel_box.dart';
import 'widgets/home_profile_drawer.dart';

// ==================== HOME PAGE ====================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    const Color backgroundColor = Color(0xFF121634);
    const Color subtitleColor = Color(0xFF8E9CB8);
    const Color primaryYellow = Color(0xFFFDBB3A);

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: HomeProfileDrawer(controller: controller),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================== TOP BAR ====================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (scaffoldContext) {
                      return GestureDetector(
                        onTap: () => Scaffold.of(scaffoldContext).openDrawer(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2852),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF2C3970), width: 1.2),
                          ),
                          child: const Icon(
                            Icons.menu_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      );
                    },
                  ),
                  const Text(
                    'BABUL SHOOTING',
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2852),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF2C3970), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: primaryYellow, size: 20),
                          const SizedBox(width: 5),
                          Text(
                            '${controller.totalStars.value} / 30',
                            style: const TextStyle(
                              color: primaryYellow,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        final String name = controller.authController.currentUser.value?.name ?? 'Player';
                        return Text(
                          'Hi, $name 👋',
                          style: const TextStyle(
                            color: Color(0xFF9FB2DC),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }),
                      const SizedBox(height: 2),
                      const Text(
                        'Select Level',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ==================== LEVEL SELECTION GRID ====================
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    final int level = index + 1;
                    return Obx(() {
                      final bool isLocked = level > controller.unlockedLevel.value;
                      final int stars = controller.levelStars[level] ?? 0;
                      final bool isSelected = level == controller.selectedLevel.value;

                      return CustomLevelBox(
                        levelNumber: level,
                        isLocked: isLocked,
                        isSelected: isSelected,
                        stars: stars,
                        onTap: () => controller.onLevelTap(level),
                      );
                    });
                  },
                ),
              ),

              // ==================== BOTTOM PLAY ACTION ====================
              Padding(
                padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
                child: Obx(() {
                  final int lvl = controller.selectedLevel.value;
                  return SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryYellow,
                        foregroundColor: const Color(0xFF131938),
                        elevation: 8,
                        shadowColor: primaryYellow.withValues(alpha: 0.50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(29),
                        ),
                      ),
                      onPressed: () => controller.playSelectedLevel(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow_rounded, size: 30),
                          const SizedBox(width: 8),
                          Text(
                            'PLAY LEVEL $lvl',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
