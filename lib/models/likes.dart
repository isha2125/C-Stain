// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class LikesModel {
  final String like_id;
  final String liked_user_id;
  final String post_id;
  final Timestamp created_at;
  LikesModel({
    required this.like_id,
    required this.liked_user_id,
    required this.post_id,
    required this.created_at,
  });

  LikesModel copyWith({
    String? like_id,
    String? liked_user_id,
    String? post_id,
    Timestamp? created_at,
  }) {
    return LikesModel(
      like_id: like_id ?? this.like_id,
      liked_user_id: liked_user_id ?? this.liked_user_id,
      post_id: post_id ?? this.post_id,
      created_at: created_at ?? this.created_at,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'like_id': like_id,
      'liked_user_id': liked_user_id,
      'post_id': post_id,
      'created_at': created_at,
    };
  }

  factory LikesModel.fromMap(Map<String, dynamic> map) {
    return LikesModel(
      like_id: map['like_id'] as String,
      liked_user_id: map['liked_user_id'] as String,
      post_id: map['post_id'] as String,
      created_at: map['created_at'] as Timestamp,
    );
  }

  String toJson() => json.encode(toMap());

  factory LikesModel.fromJson(String source) =>
      LikesModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'LikesModel(like_id: $like_id, liked_user_id: $liked_user_id, post_id: $post_id, created_at: $created_at)';
  }

  @override
  bool operator ==(covariant LikesModel other) {
    if (identical(this, other)) return true;

    return other.like_id == like_id &&
        other.liked_user_id == liked_user_id &&
        other.post_id == post_id &&
        other.created_at == created_at;
  }

  @override
  int get hashCode {
    return like_id.hashCode ^
        liked_user_id.hashCode ^
        post_id.hashCode ^
        created_at.hashCode;
  }
}
