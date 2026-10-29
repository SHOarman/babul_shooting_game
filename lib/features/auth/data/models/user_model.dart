import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final int currentLevel;
  final int totalStars;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.currentLevel = 1,
    this.totalStars = 0,
    this.createdAt,
  });

  /// Factory from Firebase User
  factory UserModel.fromFirebaseUser(User user, {String? displayName}) {
    return UserModel(
      uid: user.uid,
      name: displayName ?? user.displayName ?? 'Player',
      email: user.email ?? '',
      currentLevel: 1,
      totalStars: 0,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  /// Factory from Map / JSON
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] as String? ?? 'Player',
      email: map['email'] as String? ?? '',
      currentLevel: map['currentLevel'] as int? ?? 1,
      totalStars: map['totalStars'] as int? ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Convert to Map for saving (Firestore / Local storage)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'currentLevel': currentLevel,
      'totalStars': totalStars,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    int? currentLevel,
    int? totalStars,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      currentLevel: currentLevel ?? this.currentLevel,
      totalStars: totalStars ?? this.totalStars,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

