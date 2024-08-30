// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String post_id;
  final String title;
  final String body;
  final String posted_user_id;
  final String status;
  final Timestamp created_at;
  PostModel({
    required this.post_id,
    required this.title,
    required this.body,
    required this.posted_user_id,
    required this.status,
    required this.created_at,
  });

  PostModel copyWith({
    String? post_id,
    String? title,
    String? body,
    String? posted_user_id,
    String? status,
    Timestamp? created_at,
  }) {
    return PostModel(
      post_id: post_id ?? this.post_id,
      title: title ?? this.title,
      body: body ?? this.body,
      posted_user_id: posted_user_id ?? this.posted_user_id,
      status: status ?? this.status,
      created_at: created_at ?? this.created_at,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'post_id': post_id,
      'title': title,
      'body': body,
      'posted_user_id': posted_user_id,
      'status': status,
      'created_at': created_at,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      post_id: map['post_id'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      posted_user_id: map['posted_user_id'] as String,
      status: map['status'] as String,
      created_at: map['created_at'] as Timestamp,
    );
  }

  String toJson() => json.encode(toMap());

  factory PostModel.fromJson(String source) =>
      PostModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PostModel(post_id: $post_id, title: $title, body: $body, posted_user_id: $posted_user_id, status: $status, created_at: $created_at)';
  }

  @override
  bool operator ==(covariant PostModel other) {
    if (identical(this, other)) return true;

    return other.post_id == post_id &&
        other.title == title &&
        other.body == body &&
        other.posted_user_id == posted_user_id &&
        other.status == status &&
        other.created_at == created_at;
  }

  @override
  int get hashCode {
    return post_id.hashCode ^
        title.hashCode ^
        body.hashCode ^
        posted_user_id.hashCode ^
        status.hashCode ^
        created_at.hashCode;
  }
}
