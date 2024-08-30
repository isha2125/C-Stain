// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class CommentsModel {
  final String comment_id;
  final String comment_text;
  final String commented_user_id;
  final String post_id;
  final Timestamp created_at;
  CommentsModel({
    required this.comment_id,
    required this.comment_text,
    required this.commented_user_id,
    required this.post_id,
    required this.created_at,
  });

  CommentsModel copyWith({
    String? comment_id,
    String? comment_text,
    String? commented_user_id,
    String? post_id,
    Timestamp? created_at,
  }) {
    return CommentsModel(
      comment_id: comment_id ?? this.comment_id,
      comment_text: comment_text ?? this.comment_text,
      commented_user_id: commented_user_id ?? this.commented_user_id,
      post_id: post_id ?? this.post_id,
      created_at: created_at ?? this.created_at,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'comment_id': comment_id,
      'comment_text': comment_text,
      'commented_user_id': commented_user_id,
      'post_id': post_id,
      'created_at': created_at,
    };
  }

  factory CommentsModel.fromMap(Map<String, dynamic> map) {
    return CommentsModel(
      comment_id: map['comment_id'] as String,
      comment_text: map['comment_text'] as String,
      commented_user_id: map['commented_user_id'] as String,
      post_id: map['post_id'] as String,
      created_at: map['created_at'] as Timestamp,
    );
  }

  String toJson() => json.encode(toMap());

  factory CommentsModel.fromJson(String source) =>
      CommentsModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CommentsModel(comment_id: $comment_id, comment_text: $comment_text, commented_user_id: $commented_user_id, post_id: $post_id, created_at: $created_at)';
  }

  @override
  bool operator ==(covariant CommentsModel other) {
    if (identical(this, other)) return true;

    return other.comment_id == comment_id &&
        other.comment_text == comment_text &&
        other.commented_user_id == commented_user_id &&
        other.post_id == post_id &&
        other.created_at == created_at;
  }

  @override
  int get hashCode {
    return comment_id.hashCode ^
        comment_text.hashCode ^
        commented_user_id.hashCode ^
        post_id.hashCode ^
        created_at.hashCode;
  }
}
