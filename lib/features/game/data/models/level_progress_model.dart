import '../../domain/entities/level_progress_entity.dart';

class LevelProgressModel extends LevelProgressEntity {
  const LevelProgressModel({
    required super.level,
    required super.stars,
    required super.highScore,
    required super.isUnlocked,
  });

  factory LevelProgressModel.fromEntity(LevelProgressEntity entity) {
    return LevelProgressModel(
      level: entity.level,
      stars: entity.stars,
      highScore: entity.highScore,
      isUnlocked: entity.isUnlocked,
    );
  }

  factory LevelProgressModel.fromJson(Map<String, dynamic> json) {
    return LevelProgressModel(
      level: json['level'] as int? ?? 1,
      stars: json['stars'] as int? ?? 0,
      highScore: json['highScore'] as int? ?? 0,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'stars': stars,
      'highScore': highScore,
      'isUnlocked': isUnlocked,
    };
  }
}

