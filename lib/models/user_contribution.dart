// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserContributionModel {
  final String action;
  final String category;
  final double co2_saved;
  final Timestamp created_at;
  final int duration;
  final String userid;
  final String visibility;

  UserContributionModel({
    required this.action,
    required this.category,
    required this.co2_saved,
    required this.created_at,
    required this.duration,
    required this.userid,
    required this.visibility,
  });

  UserContributionModel copyWith({
    String? action,
    String? category,
    double? co2_saved,
    Timestamp? created_at,
    int? duration,
    String? userid,
    String? visibility,
  }) {
    return UserContributionModel(
      action: action ?? this.action,
      category: category ?? this.category,
      co2_saved: co2_saved ?? this.co2_saved,
      created_at: created_at ?? this.created_at,
      duration: duration ?? this.duration,
      userid: userid ?? this.userid,
      visibility: visibility ?? this.visibility,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'action': action,
      'category': category,
      'co2_saved': co2_saved,
      'created_at': created_at,
      'duration': duration,
      'userid': userid,
      'visibility': visibility,
    };
  }

  factory UserContributionModel.fromMap(Map<String, dynamic> map) {
    return UserContributionModel(
      action: map['action'] as String,
      category: map['category'] as String,
      co2_saved: map['co2_saved'] as double,
      created_at: map['created_at'] as Timestamp,
      duration: map['duration'] as int,
      userid: map['userid'] as String,
      visibility: map['visibility'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserContributionModel.fromJson(String source) =>
      UserContributionModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserContributionModel(action: $action, category: $category, co2_saved: $co2_saved, created_at: $created_at, duration: $duration, userid: $userid, visibility: $visibility)';
  }

  @override
  bool operator ==(covariant UserContributionModel other) {
    if (identical(this, other)) return true;

    return other.action == action &&
        other.category == category &&
        other.co2_saved == co2_saved &&
        other.created_at == created_at &&
        other.duration == duration &&
        other.userid == userid &&
        other.visibility == visibility;
  }

  @override
  int get hashCode {
    return action.hashCode ^
        category.hashCode ^
        co2_saved.hashCode ^
        created_at.hashCode ^
        duration.hashCode ^
        userid.hashCode ^
        visibility.hashCode;
  }
}
