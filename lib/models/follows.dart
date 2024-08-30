// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class FollowsModel {
  final String follower_user_id;
  final String following_user_id;
  final Timestamp created_at;
  FollowsModel({
    required this.follower_user_id,
    required this.following_user_id,
    required this.created_at,
  });

  FollowsModel copyWith({
    String? follower_user_id,
    String? following_user_id,
    Timestamp? created_at,
  }) {
    return FollowsModel(
      follower_user_id: follower_user_id ?? this.follower_user_id,
      following_user_id: following_user_id ?? this.following_user_id,
      created_at: created_at ?? this.created_at,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'follower_user_id': follower_user_id,
      'following_user_id': following_user_id,
      'created_at': created_at,
    };
  }

  factory FollowsModel.fromMap(Map<String, dynamic> map) {
    return FollowsModel(
      follower_user_id: map['follower_user_id'] as String,
      following_user_id: map['following_user_id'] as String,
      created_at: map['created_at'] as Timestamp,
    );
  }

  String toJson() => json.encode(toMap());

  factory FollowsModel.fromJson(String source) =>
      FollowsModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'FollowsModel(follower_user_id: $follower_user_id, following_user_id: $following_user_id, created_at: $created_at)';

  @override
  bool operator ==(covariant FollowsModel other) {
    if (identical(this, other)) return true;

    return other.follower_user_id == follower_user_id &&
        other.following_user_id == following_user_id &&
        other.created_at == created_at;
  }

  @override
  int get hashCode =>
      follower_user_id.hashCode ^
      following_user_id.hashCode ^
      created_at.hashCode;
}
