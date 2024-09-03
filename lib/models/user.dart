// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String bio;
  final Timestamp created_at;
  final String email;
  final String full_name;
  final String profile_picture_url;
  final double total_CO2_saved;
  final String username;
  final int streak; // New property
  final Timestamp lastLoginDate; // New property
  UserModel({
    required this.uid,
    required this.bio,
    required this.created_at,
    required this.email,
    required this.full_name,
    required this.profile_picture_url,
    required this.total_CO2_saved,
    required this.username,
    required this.streak, // Add this
    required this.lastLoginDate, // A
  });

  UserModel copyWith({
    String? uid,
    String? bio,
    Timestamp? created_at,
    String? email,
    String? full_name,
    String? profile_picture_url,
    double? total_CO2_saved,
    String? username,
    int? streak,
    Timestamp? lastLoginDate,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      bio: bio ?? this.bio,
      created_at: created_at ?? this.created_at,
      email: email ?? this.email,
      full_name: full_name ?? this.full_name,
      profile_picture_url: profile_picture_url ?? this.profile_picture_url,
      total_CO2_saved: total_CO2_saved ?? this.total_CO2_saved,
      username: username ?? this.username,
      streak: streak ?? this.streak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'bio': bio,
      'created_at': created_at,
      'email': email,
      'full_name': full_name,
      'profile_picture_url': profile_picture_url,
      'total_CO2_saved': total_CO2_saved,
      'username': username,
      'streak': streak,
      'lastLoginDate': lastLoginDate,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      bio: map['bio'] as String,
      created_at: (map['created_at'] as Timestamp),
      email: map['email'] as String,
      full_name: map['full_name'] as String,
      profile_picture_url: map['profile_picture_url'] as String,
      total_CO2_saved: map['total_CO2_saved'] as double,
      username: map['username'] as String,
      streak: map['streak'] as int,
      lastLoginDate: map['lastLoginDate'] as Timestamp,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(uid: $uid, bio: $bio, created_at: $created_at, email: $email, full_name: $full_name, profile_picture_url: $profile_picture_url, total_CO2_saved: $total_CO2_saved, username: $username,streak: $streak, lastLoginDate: $lastLoginDate)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.bio == bio &&
        other.created_at == created_at &&
        other.email == email &&
        other.full_name == full_name &&
        other.profile_picture_url == profile_picture_url &&
        other.total_CO2_saved == total_CO2_saved &&
        other.username == username &&
        other.streak == streak &&
        other.lastLoginDate == lastLoginDate;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        bio.hashCode ^
        created_at.hashCode ^
        email.hashCode ^
        full_name.hashCode ^
        profile_picture_url.hashCode ^
        total_CO2_saved.hashCode ^
        username.hashCode ^
        streak.hashCode ^
        lastLoginDate.hashCode;
  }
}
