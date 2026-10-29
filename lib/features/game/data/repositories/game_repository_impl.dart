import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/level_progress_entity.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/game_local_datasource.dart';
import '../datasources/game_remote_datasource.dart';

// ==================== GAME REPOSITORY IMPLEMENTATION ====================
class GameRepositoryImpl implements GameRepository {
  final GameLocalDataSource _localDataSource;
  final GameRemoteDataSource _remoteDataSource;

  GameRepositoryImpl({
    GameLocalDataSource? localDataSource,
    GameRemoteDataSource? remoteDataSource,
  })  : _localDataSource = localDataSource ?? GameLocalDataSourceImpl(),
        _remoteDataSource = remoteDataSource ?? GameRemoteDataSourceImpl();

  @override
  Future<List<LevelProgressEntity>> getAllLevelProgress() async {
    return await _localDataSource.getLevelProgressList();
  }

  @override
  Future<int> getTotalStars() async {
    return await _localDataSource.getTotalStars();
  }

  @override
  Future<int> getUnlockedLevel() async {
    return await _localDataSource.getUnlockedLevel();
  }

  @override
  Future<LevelProgressEntity> saveLevelResult({
    required int level,
    required int stars,
    required int score,
  }) async {
    final localResult = await _localDataSource.saveLevelProgress(
      level: level,
      stars: stars,
      score: score,
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.uid.isNotEmpty) {
        final int unlocked = await _localDataSource.getUnlockedLevel();
        await _remoteDataSource.saveLevelProgress(
          uid: user.uid,
          level: level,
          stars: localResult.stars,
          score: localResult.highScore,
          unlockedLevel: unlocked,
        );
      }
    } catch (e) {
      debugPrint('[Cloud Save Note] $e');
    }

    return localResult;
  }

  @override
  Future<void> syncWithCloud() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.uid.isEmpty) return;

      final remoteData = await _remoteDataSource.getUserGameData(user.uid);

      if (remoteData != null) {
        final int rUnlocked = (remoteData['unlockedLevel'] as num?)?.toInt() ?? 1;
        if (rUnlocked > 1) {
          await _localDataSource.setUnlockedLevel(rUnlocked);
        }

        for (int lvl = 1; lvl <= 10; lvl++) {
          final int rStars = (remoteData['level_${lvl}_stars'] as num?)?.toInt() ?? 0;
          final int rScore = (remoteData['level_${lvl}_score'] as num?)?.toInt() ?? 0;
          if (rStars > 0 || rScore > 0) {
            await _localDataSource.saveLevelProgress(
              level: lvl,
              stars: rStars,
              score: rScore,
            );
          }
        }
      }

      final localList = await _localDataSource.getLevelProgressList();
      final int localUnlocked = await _localDataSource.getUnlockedLevel();
      final Map<int, int> starsMap = {};
      final Map<int, int> scoreMap = {};

      for (final item in localList) {
        if (item.stars > 0) starsMap[item.level] = item.stars;
        if (item.highScore > 0) scoreMap[item.level] = item.highScore;
      }

      await _remoteDataSource.syncFullProgress(
        uid: user.uid,
        email: user.email,
        name: user.displayName,
        unlockedLevel: localUnlocked,
        starsMap: starsMap,
        scoreMap: scoreMap,
      );
    } catch (e) {
      debugPrint('[Cloud Sync Error] $e');
    }
  }

  @override
  Future<void> resetProgress() async {
    await _localDataSource.clearAll();
  }
}
