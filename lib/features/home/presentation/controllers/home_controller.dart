import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../game/domain/usecases/get_level_progress_usecase.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

// ==================== HOME CONTROLLER ====================
class HomeController extends GetxController {
  final GetLevelProgressUseCase _getLevelProgressUseCase;

  HomeController({GetLevelProgressUseCase? getLevelProgressUseCase})
      : _getLevelProgressUseCase = getLevelProgressUseCase ?? Get.find<GetLevelProgressUseCase>();

  final AuthController authController = Get.find<AuthController>();

  // ==================== REACTIVE STATE ====================
  final RxInt totalStars = 0.obs;
  final RxInt unlockedLevel = 1.obs;
  final RxInt selectedLevel = 1.obs;
  final RxMap<int, int> levelStars = <int, int>{
    1: 0, 2: 0, 3: 0, 4: 0, 5: 0,
    6: 0, 7: 0, 8: 0, 9: 0, 10: 0,
  }.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProgress();
    authController.currentUser.listen((_) {
      loadProgress();
    });
  }

  // ==================== LEVEL PROGRESS ====================
  Future<void> loadProgress() async {
    try {
      isLoading.value = true;
      await _refreshProgressState();

      await _getLevelProgressUseCase.syncWithCloud();
      await _refreshProgressState();
    } catch (e) {
      debugPrint('Error loading level progress: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _refreshProgressState() async {
    final progressList = await _getLevelProgressUseCase.execute();
    int starsSum = 0;

    for (var item in progressList) {
      levelStars[item.level] = item.stars;
      starsSum += item.stars;
    }

    totalStars.value = starsSum;
    final int unlocked = await _getLevelProgressUseCase.getUnlockedLevel();
    unlockedLevel.value = unlocked;

    if (selectedLevel.value > unlocked) {
      selectedLevel.value = unlocked;
    }
  }

  // ==================== NAVIGATION & GAMEPLAY ====================
  void onLevelTap(int level) {
    if (level > unlockedLevel.value) {
      Get.snackbar(
        'Level Locked',
        'Complete Level ${unlockedLevel.value} to unlock Level $level!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1E2850),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    selectedLevel.value = level;
  }

  Future<void> playSelectedLevel() async {
    await playLevel(selectedLevel.value);
  }

  Future<void> playLevel([int? targetLevel]) async {
    final int levelToPlay = targetLevel ?? selectedLevel.value;

    final result = await Get.toNamed(
      AppRoutes.game,
      arguments: {'level': levelToPlay},
    );

    await loadProgress();

    if (result is Map && result['won'] == true) {
      if (levelToPlay < 10) {
        selectedLevel.value = (levelToPlay + 1).clamp(1, unlockedLevel.value);
      }
    }
  }
}
