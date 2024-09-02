// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class AchievementsModel {
  final String achievement_id;
  final String name;
  final String description;
  final double co2_threshold;
  final Timestamp created_at;
  AchievementsModel({
    required this.achievement_id,
    required this.name,
    required this.description,
    required this.co2_threshold,
    required this.created_at,
  });

  AchievementsModel copyWith({
    String? achievement_id,
    String? name,
    String? description,
    double? co2_threshold,
    Timestamp? created_at,
  }) {
    return AchievementsModel(
      achievement_id: achievement_id ?? this.achievement_id,
      name: name ?? this.name,
      description: description ?? this.description,
      co2_threshold: co2_threshold ?? this.co2_threshold,
      created_at: created_at ?? this.created_at,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'achievement_id': achievement_id,
      'name': name,
      'description': description,
      'co2_threshold': co2_threshold,
      'created_at': created_at,
    };
  }

  factory AchievementsModel.fromMap(Map<String, dynamic> map) {
    return AchievementsModel(
      achievement_id: map['achievement_id'] as String? ?? "random id",
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      co2_threshold: (map['co2_threshold'] as num?)?.toDouble() ?? 500.0,
      created_at: map['created_at'] as Timestamp,
    );
  }

  String toJson() => json.encode(toMap());

  factory AchievementsModel.fromJson(String source) =>
      AchievementsModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AchievementsModel(achievement_id: $achievement_id, name: $name, description: $description, co2_threshold: $co2_threshold, created_at: $created_at)';
  }

  @override
  bool operator ==(covariant AchievementsModel other) {
    if (identical(this, other)) return true;

    return other.achievement_id == achievement_id &&
        other.name == name &&
        other.description == description &&
        other.co2_threshold == co2_threshold &&
        other.created_at == created_at;
  }

  @override
  int get hashCode {
    return achievement_id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        co2_threshold.hashCode ^
        created_at.hashCode;
  }
}
