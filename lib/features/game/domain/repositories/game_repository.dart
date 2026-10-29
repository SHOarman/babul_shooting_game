import '../entities/level_progress_entity.dart';

// ==================== GAME REPOSITORY INTERFACE ====================
abstract class GameRepository {
  Future<List<LevelProgressEntity>> getAllLevelProgress();
  Future<int> getTotalStars();
  Future<int> getUnlockedLevel();
  Future<LevelProgressEntity> saveLevelResult({
    required int level,
    required int stars,
    required int score,
  });
  Future<void> syncWithCloud();
  Future<void> resetProgress();
}
