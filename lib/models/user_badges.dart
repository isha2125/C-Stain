// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserBadgesModel {
  final String badge_id;
  final Timestamp earned_at;
  final String user_id;
  UserBadgesModel({
    required this.badge_id,
    required this.earned_at,
    required this.user_id,
  });

  UserBadgesModel copyWith({
    String? badge_id,
    Timestamp? earned_at,
    String? user_id,
  }) {
    return UserBadgesModel(
      badge_id: badge_id ?? this.badge_id,
      earned_at: earned_at ?? this.earned_at,
      user_id: user_id ?? this.user_id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'badge_id': badge_id,
      'earned_at': earned_at,
      'user_id': user_id,
    };
  }

  factory UserBadgesModel.fromMap(Map<String, dynamic> map) {
    return UserBadgesModel(
      badge_id: map['badge_id'] as String,
      earned_at: map['earned_at'] as Timestamp,
      user_id: map['user_id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserBadgesModel.fromJson(String source) =>
      UserBadgesModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'UserBadgesModel(badge_id: $badge_id, earned_at: $earned_at, user_id: $user_id)';

  @override
  bool operator ==(covariant UserBadgesModel other) {
    if (identical(this, other)) return true;

    return other.badge_id == badge_id &&
        other.earned_at == earned_at &&
        other.user_id == user_id;
  }

  @override
  int get hashCode => badge_id.hashCode ^ earned_at.hashCode ^ user_id.hashCode;
}
