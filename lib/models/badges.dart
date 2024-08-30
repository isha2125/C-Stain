// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class BadgesModel {
  final String badge_id;
  final String name;
  final String description;
  final double co2_threshold;
  final int time_period;
  final Timestamp created_at;
  BadgesModel({
    required this.badge_id,
    required this.name,
    required this.description,
    required this.co2_threshold,
    required this.time_period,
    required this.created_at,
  });

  BadgesModel copyWith({
    String? badge_id,
    String? name,
    String? description,
    double? co2_threshold,
    int? time_period,
    Timestamp? created_at,
  }) {
    return BadgesModel(
      badge_id: badge_id ?? this.badge_id,
      name: name ?? this.name,
      description: description ?? this.description,
      co2_threshold: co2_threshold ?? this.co2_threshold,
      time_period: time_period ?? this.time_period,
      created_at: created_at ?? this.created_at,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'badge_id': badge_id,
      'name': name,
      'description': description,
      'co2_threshold': co2_threshold,
      'time_period': time_period,
      'created_at': created_at,
    };
  }

  factory BadgesModel.fromMap(Map<String, dynamic> map) {
    return BadgesModel(
      badge_id: map['badge_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      co2_threshold: map['co2_threshold'] as double,
      time_period: map['time_period'] as int,
      created_at: map['created_at'] as Timestamp,
    );
  }

  String toJson() => json.encode(toMap());

  factory BadgesModel.fromJson(String source) =>
      BadgesModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BadgesModel(badge_id: $badge_id, name: $name, description: $description, co2_threshold: $co2_threshold, time_period: $time_period, created_at: $created_at)';
  }

  @override
  bool operator ==(covariant BadgesModel other) {
    if (identical(this, other)) return true;

    return other.badge_id == badge_id &&
        other.name == name &&
        other.description == description &&
        other.co2_threshold == co2_threshold &&
        other.time_period == time_period &&
        other.created_at == created_at;
  }

  @override
  int get hashCode {
    return badge_id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        co2_threshold.hashCode ^
        time_period.hashCode ^
        created_at.hashCode;
  }
}
