// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserAchievementsModel {
  final String achievement_id;
  final Timestamp earned_at;
  final String user_id;
  UserAchievementsModel({
    required this.achievement_id,
    required this.earned_at,
    required this.user_id,
  });

  UserAchievementsModel copyWith({
    String? achievement_id,
    Timestamp? earned_at,
    String? user_id,
  }) {
    return UserAchievementsModel(
      achievement_id: achievement_id ?? this.achievement_id,
      earned_at: earned_at ?? this.earned_at,
      user_id: user_id ?? this.user_id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'achievement_id': achievement_id,
      'earned_at': earned_at,
      'user_id': user_id,
    };
  }

  factory UserAchievementsModel.fromMap(Map<String, dynamic> map) {
    return UserAchievementsModel(
      achievement_id: map['achievement_id'] as String,
      earned_at: map['earned_at'] as Timestamp,
      user_id: map['user_id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserAchievementsModel.fromJson(String source) =>
      UserAchievementsModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'UserAchievementsModel(achievement_id: $achievement_id, earned_at: $earned_at, user_id: $user_id)';

  @override
  bool operator ==(covariant UserAchievementsModel other) {
    if (identical(this, other)) return true;

    return other.achievement_id == achievement_id &&
        other.earned_at == earned_at &&
        other.user_id == user_id;
  }

  @override
  int get hashCode =>
      achievement_id.hashCode ^ earned_at.hashCode ^ user_id.hashCode;
}
