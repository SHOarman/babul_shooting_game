import '../entities/level_progress_entity.dart';
import '../repositories/game_repository.dart';

class GetLevelProgressUseCase {
  final GameRepository _repository;

  GetLevelProgressUseCase(this._repository);

  Future<List<LevelProgressEntity>> execute() async {
    return await _repository.getAllLevelProgress();
  }

  Future<int> getTotalStars() async {
    return await _repository.getTotalStars();
  }

  Future<int> getUnlockedLevel() async {
    return await _repository.getUnlockedLevel();
  }

  Future<void> syncWithCloud() async {
    await _repository.syncWithCloud();
  }
}

