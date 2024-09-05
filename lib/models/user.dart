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
  final int currentStreak; // New property
  final Timestamp lastActivityDate; // New property
  final bool streak_sunday;
  final bool streak_monday;
  final bool streak_tuesday;
  final bool streak_wednesday;
  final bool streak_thursday;
  final bool streak_friday;
  final bool streak_saturday;
  UserModel({
    required this.uid,
    required this.bio,
    required this.created_at,
    required this.email,
    required this.full_name,
    required this.profile_picture_url,
    required this.total_CO2_saved,
    required this.username,
    required this.currentStreak,
    required this.lastActivityDate,
    required this.streak_sunday,
    required this.streak_monday,
    required this.streak_tuesday,
    required this.streak_wednesday,
    required this.streak_thursday,
    required this.streak_friday,
    required this.streak_saturday,
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
    int? currentStreak,
    Timestamp? lastActivityDate,
    bool? streak_sunday,
    bool? streak_monday,
    bool? streak_tuesday,
    bool? streak_wednesday,
    bool? streak_thursday,
    bool? streak_friday,
    bool? streak_saturday,
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
      currentStreak: currentStreak ?? this.currentStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      streak_sunday: streak_sunday ?? this.streak_sunday,
      streak_monday: streak_monday ?? this.streak_monday,
      streak_tuesday: streak_tuesday ?? this.streak_tuesday,
      streak_wednesday: streak_wednesday ?? this.streak_wednesday,
      streak_thursday: streak_thursday ?? this.streak_thursday,
      streak_friday: streak_friday ?? this.streak_friday,
      streak_saturday: streak_saturday ?? this.streak_saturday,
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
      'currentStreak': currentStreak,
      'lastActivityDate': lastActivityDate,
      'streak_sunday': streak_sunday,
      'streak_monday': streak_monday,
      'streak_tuesday': streak_tuesday,
      'streak_wednesday': streak_wednesday,
      'streak_thursday': streak_thursday,
      'streak_friday': streak_friday,
      'streak_saturday': streak_saturday,
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
      currentStreak: map['currentStreak'] as int,
      lastActivityDate: map['lastActivityDate'] as Timestamp,
      streak_sunday: map['streak_sunday'] as bool,
      streak_monday: map['streak_monday'] as bool,
      streak_tuesday: map['streak_tuesday'] as bool,
      streak_wednesday: map['streak_wednesday'] as bool,
      streak_thursday: map['streak_thursday'] as bool,
      streak_friday: map['streak_friday'] as bool,
      streak_saturday: map['streak_saturday'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(uid: $uid, bio: $bio, created_at: $created_at, email: $email, full_name: $full_name, profile_picture_url: $profile_picture_url, total_CO2_saved: $total_CO2_saved, username: $username, currentStreak: $currentStreak, lastActivityDate: $lastActivityDate, streak_sunday: $streak_sunday, streak_monday: $streak_monday, streak_tuesday: $streak_tuesday, streak_wednesday: $streak_wednesday, streak_thursday: $streak_thursday, streak_friday: $streak_friday, streak_saturday: $streak_saturday)';
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
        other.currentStreak == currentStreak &&
        other.lastActivityDate == lastActivityDate &&
        other.streak_sunday == streak_sunday &&
        other.streak_monday == streak_monday &&
        other.streak_tuesday == streak_tuesday &&
        other.streak_wednesday == streak_wednesday &&
        other.streak_thursday == streak_thursday &&
        other.streak_friday == streak_friday &&
        other.streak_saturday == streak_saturday;
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
        currentStreak.hashCode ^
        lastActivityDate.hashCode ^
        streak_sunday.hashCode ^
        streak_monday.hashCode ^
        streak_tuesday.hashCode ^
        streak_wednesday.hashCode ^
        streak_thursday.hashCode ^
        streak_friday.hashCode ^
        streak_saturday.hashCode;
  }
}
