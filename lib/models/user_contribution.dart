// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserContributionModel {
  final String contribution_id;
  final String action;
  final String category;
  final double co2_saved;
  final Timestamp created_at;
  final double duration;
  final String user_id;
  UserContributionModel({
    required this.contribution_id,
    required this.action,
    required this.category,
    required this.co2_saved,
    required this.created_at,
    required this.duration,
    required this.user_id,
  });

  UserContributionModel copyWith({
    String? contribution_id,
    String? action,
    String? category,
    double? co2_saved,
    Timestamp? created_at,
    double? duration,
    String? user_id,
  }) {
    return UserContributionModel(
      contribution_id: contribution_id ?? this.contribution_id,
      action: action ?? this.action,
      category: category ?? this.category,
      co2_saved: co2_saved ?? this.co2_saved,
      created_at: created_at ?? this.created_at,
      duration: duration ?? this.duration,
      user_id: user_id ?? this.user_id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'contribution_id': contribution_id,
      'action': action,
      'category': category,
      'co2_saved': co2_saved,
      'created_at': created_at,
      'duration': duration,
      'user_id': user_id,
    };
  }

  factory UserContributionModel.fromMap(Map<String, dynamic> map) {
    return UserContributionModel(
      contribution_id: map['contribution_id'] as String,
      action: map['action'] as String,
      category: map['category'] as String,
      co2_saved: (map['co2_saved'] as num).toDouble(),
      created_at: (map['created_at'] as Timestamp),
      duration: (map['duration'] as num).toDouble(),
      user_id: map['user_id'] as String,
    );
  }
  DateTime get createdAtDateTime => created_at.toDate();

  String toJson() => json.encode(toMap());

  factory UserContributionModel.fromJson(String source) =>
      UserContributionModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserContributionModel(contribution_id: $contribution_id, action: $action, category: $category, co2_saved: $co2_saved, created_at: $created_at, duration: $duration, user_id: $user_id)';
  }

  @override
  bool operator ==(covariant UserContributionModel other) {
    if (identical(this, other)) return true;

    return other.contribution_id == contribution_id &&
        other.action == action &&
        other.category == category &&
        other.co2_saved == co2_saved &&
        other.created_at == created_at &&
        other.duration == duration &&
        other.user_id == user_id;
  }

  @override
  int get hashCode {
    return contribution_id.hashCode ^
        action.hashCode ^
        category.hashCode ^
        co2_saved.hashCode ^
        created_at.hashCode ^
        duration.hashCode ^
        user_id.hashCode;
  }
}
