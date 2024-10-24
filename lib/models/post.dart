// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

// Future<void> savePost(String mediaUrl) async {
//   await FirebaseFirestore.instance.collection('posts').add({
// //    'body': _controller.text,
// //    'title': _titleController.text,
//    // 'created_at': Timestamp.now(),
//   //  'posted_user_id': 'saviour123', // Replace with the actual user ID
//    // 'status': 'posted',
//     'media_url': mediaUrl,
//     'media_type': _mediaType,
//     'visibility': 'public',
//   });
class PostModel {
  final String post_id;
  final String title;
  final String body;
  final String posted_user_id;
  final String status;
  final Timestamp created_at;
  final String? media_url;
  final String media_type;
  final String visibility;
  final String posted_user_username;
  final int likes_count;
  PostModel({
    required this.post_id,
    required this.title,
    required this.body,
    required this.posted_user_id,
    required this.status,
    required this.created_at,
    this.media_url,
    required this.media_type,
    required this.visibility,
    required this.posted_user_username,
    this.likes_count = 0,
  });

  PostModel copyWith({
    String? post_id,
    String? title,
    String? body,
    String? posted_user_id,
    String? status,
    Timestamp? created_at,
    String? media_url,
    String? media_type,
    String? visibility,
    String? posted_user_username,
    int? likes_count,
  }) {
    return PostModel(
      post_id: post_id ?? this.post_id,
      title: title ?? this.title,
      body: body ?? this.body,
      posted_user_id: posted_user_id ?? this.posted_user_id,
      status: status ?? this.status,
      created_at: created_at ?? this.created_at,
      media_url: media_url ?? this.media_url,
      media_type: media_type ?? this.media_type,
      visibility: visibility ?? this.visibility,
      posted_user_username: posted_user_username ?? this.posted_user_username,
      likes_count: likes_count ?? this.likes_count,
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
      'media_url': media_url,
      'media_type': media_type,
      'visibility': visibility,
      'posted_user_username': posted_user_username,
      'likes_count': likes_count,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      post_id: map['post_id'] ?? '',
      title: map['title'] ?? 'Untitled Post',
      body: map['body'] ?? '',
      posted_user_id: map['posted_user_id'] ?? '',
      status: map['status'] ?? 'active',
      created_at: map['created_at'] ?? DateTime.now(),
      media_url: map['media_url'] != null ? map['media_url'] as String : null,
      //media_url: map['media_url'] ?? '',
      media_type: map['media_type'] ?? '',
      visibility: map['visibility'] ?? 'public',
      posted_user_username: map['posted_user_username'] ?? 'Anonymous',
      likes_count: map['likes_count'] != null ? map['likes_count'] as int : 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory PostModel.fromJson(String source) =>
      PostModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PostModel(post_id: $post_id, title: $title, body: $body, posted_user_id: $posted_user_id, status: $status, created_at: $created_at, media_url: $media_url, media_type: $media_type, visibility: $visibility, posted_user_username: $posted_user_username, likes_count: $likes_count)';
  }

  @override
  bool operator ==(covariant PostModel other) {
    if (identical(this, other)) return true;

    return other.post_id == post_id &&
        other.title == title &&
        other.body == body &&
        other.posted_user_id == posted_user_id &&
        other.status == status &&
        other.created_at == created_at &&
        other.media_url == media_url &&
        other.media_type == media_type &&
        other.visibility == visibility &&
        other.posted_user_username == posted_user_username &&
        other.likes_count == likes_count;
  }

  @override
  int get hashCode {
    return post_id.hashCode ^
        title.hashCode ^
        body.hashCode ^
        posted_user_id.hashCode ^
        status.hashCode ^
        created_at.hashCode ^
        media_url.hashCode ^
        media_type.hashCode ^
        visibility.hashCode ^
        posted_user_username.hashCode ^
        likes_count.hashCode;
  }
}
