import '../entities/level_progress_entity.dart';
import '../repositories/game_repository.dart';

class SaveLevelResultUseCase {
  final GameRepository _repository;

  SaveLevelResultUseCase(this._repository);

  Future<LevelProgressEntity> execute({
    required int level,
    required int stars,
    required int score,
  }) async {
    return await _repository.saveLevelResult(
      level: level,
      stars: stars,
      score: score,
    );
  }
}

