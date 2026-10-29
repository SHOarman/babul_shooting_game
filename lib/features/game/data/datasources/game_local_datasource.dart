import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/level_progress_model.dart';

// ==================== GAME LOCAL DATASOURCE ====================
abstract class GameLocalDataSource {
  Future<List<LevelProgressModel>> getLevelProgressList();
  Future<LevelProgressModel> saveLevelProgress({
    required int level,
    required int stars,
    required int score,
  });
  Future<int> getTotalStars();
  Future<int> getUnlockedLevel();
  Future<void> setUnlockedLevel(int level);
  Future<void> clearAll();
}

// ==================== IMPLEMENTATION ====================
class GameLocalDataSourceImpl implements GameLocalDataSource {
  Future<Map<String, String>> _getUserIdentifiers() async {
    final prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString('user_id') ?? '';
    String email = prefs.getString('user_email') ?? '';

    if (uid.isEmpty || email.isEmpty) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          if (uid.isEmpty && user.uid.isNotEmpty) uid = user.uid;
          if (email.isEmpty && user.email != null && user.email!.isNotEmpty) {
            email = user.email!;
          }
        }
      } catch (_) {}
    }

    final String cleanEmail = email.toLowerCase().trim();
    return {
      'uid': uid.isNotEmpty ? uid : 'default_player',
      'email': cleanEmail,
    };
  }

  @override
  Future<int> getUnlockedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await _getUserIdentifiers();
    final String uid = ids['uid']!;
    final String email = ids['email']!;

    final List<int> candidates = [
      prefs.getInt('${uid}_unlocked_level') ?? 1,
      if (email.isNotEmpty) prefs.getInt('${email}_unlocked_level') ?? 1,
      prefs.getInt('default_player_unlocked_level') ?? 1,
      prefs.getInt('unlocked_level') ?? 1,
    ];

    final int best = candidates.reduce(max);
    return best > 0 ? best : 1;
  }

  @override
  Future<void> setUnlockedLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await _getUserIdentifiers();
    final String uid = ids['uid']!;
    final String email = ids['email']!;

    final int current = await getUnlockedLevel();
    final int best = level > current ? level : current;

    await prefs.setInt('${uid}_unlocked_level', best);
    if (email.isNotEmpty) await prefs.setInt('${email}_unlocked_level', best);
    await prefs.setInt('default_player_unlocked_level', best);
    await prefs.setInt('unlocked_level', best);
  }

  @override
  Future<List<LevelProgressModel>> getLevelProgressList() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await _getUserIdentifiers();
    final String uid = ids['uid']!;
    final String email = ids['email']!;

    final int unlockedLevel = await getUnlockedLevel();

    final List<LevelProgressModel> list = [];
    for (int lvl = 1; lvl <= 10; lvl++) {
      final List<int> starCandidates = [
        prefs.getInt('${uid}_level_stars_$lvl') ?? 0,
        if (email.isNotEmpty) prefs.getInt('${email}_level_stars_$lvl') ?? 0,
        prefs.getInt('default_player_level_stars_$lvl') ?? 0,
        prefs.getInt('level_stars_$lvl') ?? 0,
      ];
      final int stars = starCandidates.reduce(max);

      final List<int> scoreCandidates = [
        prefs.getInt('${uid}_level_score_$lvl') ?? 0,
        if (email.isNotEmpty) prefs.getInt('${email}_level_score_$lvl') ?? 0,
        prefs.getInt('default_player_level_score_$lvl') ?? 0,
        prefs.getInt('level_score_$lvl') ?? 0,
      ];
      final int highScore = scoreCandidates.reduce(max);

      final bool isUnlocked = lvl <= unlockedLevel;

      list.add(LevelProgressModel(
        level: lvl,
        stars: stars,
        highScore: highScore,
        isUnlocked: isUnlocked,
      ));
    }
    return list;
  }

  @override
  Future<LevelProgressModel> saveLevelProgress({
    required int level,
    required int stars,
    required int score,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await _getUserIdentifiers();
    final String uid = ids['uid']!;
    final String email = ids['email']!;

    final List<int> starCandidates = [
      prefs.getInt('${uid}_level_stars_$level') ?? 0,
      if (email.isNotEmpty) prefs.getInt('${email}_level_stars_$level') ?? 0,
      prefs.getInt('default_player_level_stars_$level') ?? 0,
      prefs.getInt('level_stars_$level') ?? 0,
    ];
    final int currentStars = starCandidates.reduce(max);
    final int bestStars = stars > currentStars ? stars : currentStars;

    await prefs.setInt('${uid}_level_stars_$level', bestStars);
    if (email.isNotEmpty) await prefs.setInt('${email}_level_stars_$level', bestStars);
    await prefs.setInt('default_player_level_stars_$level', bestStars);
    await prefs.setInt('level_stars_$level', bestStars);

    final List<int> scoreCandidates = [
      prefs.getInt('${uid}_level_score_$level') ?? 0,
      if (email.isNotEmpty) prefs.getInt('${email}_level_score_$level') ?? 0,
      prefs.getInt('default_player_level_score_$level') ?? 0,
      prefs.getInt('level_score_$level') ?? 0,
    ];
    final int currentScore = scoreCandidates.reduce(max);
    final int bestScore = score > currentScore ? score : currentScore;

    await prefs.setInt('${uid}_level_score_$level', bestScore);
    if (email.isNotEmpty) await prefs.setInt('${email}_level_score_$level', bestScore);
    await prefs.setInt('default_player_level_score_$level', bestScore);
    await prefs.setInt('level_score_$level', bestScore);

    int currentUnlocked = await getUnlockedLevel();
    if (level == currentUnlocked && currentUnlocked < 10 && stars > 0) {
      currentUnlocked = level + 1;
      await prefs.setInt('${uid}_unlocked_level', currentUnlocked);
      if (email.isNotEmpty) await prefs.setInt('${email}_unlocked_level', currentUnlocked);
      await prefs.setInt('default_player_unlocked_level', currentUnlocked);
      await prefs.setInt('unlocked_level', currentUnlocked);
    }

    return LevelProgressModel(
      level: level,
      stars: bestStars,
      highScore: bestScore,
      isUnlocked: true,
    );
  }

  @override
  Future<int> getTotalStars() async {
    final list = await getLevelProgressList();
    int total = 0;
    for (final item in list) {
      total += item.stars;
    }
    return total;
  }

  @override
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await _getUserIdentifiers();
    final String uid = ids['uid']!;
    final String email = ids['email']!;

    for (int lvl = 1; lvl <= 10; lvl++) {
      await prefs.remove('${uid}_level_stars_$lvl');
      await prefs.remove('${uid}_level_score_$lvl');
      if (email.isNotEmpty) {
        await prefs.remove('${email}_level_stars_$lvl');
        await prefs.remove('${email}_level_score_$lvl');
      }
      await prefs.remove('default_player_level_stars_$lvl');
      await prefs.remove('level_stars_$lvl');
    }
    await prefs.remove('${uid}_unlocked_level');
    if (email.isNotEmpty) await prefs.remove('${email}_unlocked_level');
    await prefs.remove('default_player_unlocked_level');
    await prefs.remove('unlocked_level');
  }
}
