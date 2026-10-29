class LevelProgressEntity {
  final int level;
  final int stars; // 0, 1, 2, or 3
  final int highScore;
  final bool isUnlocked;

  const LevelProgressEntity({
    required this.level,
    required this.stars,
    required this.highScore,
    required this.isUnlocked,
  });

  LevelProgressEntity copyWith({
    int? level,
    int? stars,
    int? highScore,
    bool? isUnlocked,
  }) {
    return LevelProgressEntity(
      level: level ?? this.level,
      stars: stars ?? this.stars,
      highScore: highScore ?? this.highScore,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}

