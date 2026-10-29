import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// ==================== GAME REMOTE DATASOURCE (FIRESTORE) ====================
abstract class GameRemoteDataSource {
  Future<Map<String, dynamic>?> getUserGameData(String uid);
  Future<void> saveLevelProgress({
    required String uid,
    required int level,
    required int stars,
    required int score,
    required int unlockedLevel,
  });
  Future<void> syncFullProgress({
    required String uid,
    required String? email,
    required String? name,
    required int unlockedLevel,
    required Map<int, int> starsMap,
    required Map<int, int> scoreMap,
  });
}

// ==================== IMPLEMENTATION ====================
class GameRemoteDataSourceImpl implements GameRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<Map<String, dynamic>?> getUserGameData(String uid) async {
    if (uid.isEmpty || uid == 'default_player') return null;
    try {
      final doc = await _firestore.collection('users').doc(uid).get().timeout(const Duration(seconds: 3));
      if (doc.exists && doc.data() != null) {
        return doc.data();
      }
    } catch (e) {
      debugPrint('[Firestore Error] getUserGameData: $e');
    }
    return null;
  }

  @override
  Future<void> saveLevelProgress({
    required String uid,
    required int level,
    required int stars,
    required int score,
    required int unlockedLevel,
  }) async {
    if (uid.isEmpty || uid == 'default_player') return;
    try {
      await _firestore.collection('users').doc(uid).set({
        'unlockedLevel': unlockedLevel,
        'level_${level}_stars': stars,
        'level_${level}_score': score,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('[Firestore Error] saveLevelProgress: $e');
    }
  }

  @override
  Future<void> syncFullProgress({
    required String uid,
    required String? email,
    required String? name,
    required int unlockedLevel,
    required Map<int, int> starsMap,
    required Map<int, int> scoreMap,
  }) async {
    if (uid.isEmpty || uid == 'default_player') return;
    try {
      final Map<String, dynamic> data = {
        'uid': uid,
        if (email != null && email.isNotEmpty) 'email': email,
        if (name != null && name.isNotEmpty) 'name': name,
        'unlockedLevel': unlockedLevel,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      starsMap.forEach((lvl, stars) {
        data['level_${lvl}_stars'] = stars;
      });
      scoreMap.forEach((lvl, score) {
        data['level_${lvl}_score'] = score;
      });

      await _firestore.collection('users').doc(uid).set(data, SetOptions(merge: true)).timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('[Firestore Error] syncFullProgress: $e');
    }
  }
}

