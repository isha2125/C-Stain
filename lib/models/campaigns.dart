// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Campaign {
  final String campaignId;
  final String corpUserId;
  final String title;
  final String description;
  final String category;
  final String action;
  final double targetCO2Savings;
  final Timestamp startDate;
  final Timestamp endDate;
  final Timestamp created_at;
  Campaign({
    required this.campaignId,
    required this.corpUserId,
    required this.title,
    required this.description,
    required this.category,
    required this.action,
    required this.targetCO2Savings,
    required this.startDate,
    required this.endDate,
    required this.created_at,
  });

  Campaign copyWith({
    String? campaignId,
    String? corpUserId,
    String? title,
    String? description,
    String? category,
    String? action,
    double? targetCO2Savings,
    Timestamp? startDate,
    Timestamp? endDate,
    Timestamp? created_at,
  }) {
    return Campaign(
      campaignId: campaignId ?? this.campaignId,
      corpUserId: corpUserId ?? this.corpUserId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      action: action ?? this.action,
      targetCO2Savings: targetCO2Savings ?? this.targetCO2Savings,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      created_at: created_at ?? this.created_at,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'campaignId': campaignId,
      'corpUserId': corpUserId,
      'title': title,
      'description': description,
      'category': category,
      'action': action,
      'targetCO2Savings': targetCO2Savings,
      'startDate': startDate,
      'endDate': endDate,
      'created_at': created_at,
    };
  }

  factory Campaign.fromMap(Map<String, dynamic> map) {
    return Campaign(
      campaignId: map['campaignId'] as String,
      corpUserId: map['corpUserId'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      action: map['action'] as String,
      targetCO2Savings: map['targetCO2Savings'] as double,
      startDate: map['startDate'] as Timestamp,
      endDate: map['endDate'] as Timestamp,
      created_at: map['created_at'] as Timestamp,
    );
  }

  String toJson() => json.encode(toMap());

  factory Campaign.fromJson(String source) =>
      Campaign.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Campaign(campaignId: $campaignId, corpUserId: $corpUserId, title: $title, description: $description, category: $category, action: $action, targetCO2Savings: $targetCO2Savings, startDate: $startDate, endDate: $endDate, created_at: $created_at)';
  }

  @override
  bool operator ==(covariant Campaign other) {
    if (identical(this, other)) return true;

    return other.campaignId == campaignId &&
        other.corpUserId == corpUserId &&
        other.title == title &&
        other.description == description &&
        other.category == category &&
        other.action == action &&
        other.targetCO2Savings == targetCO2Savings &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.created_at == created_at;
  }

  @override
  int get hashCode {
    return campaignId.hashCode ^
        corpUserId.hashCode ^
        title.hashCode ^
        description.hashCode ^
        category.hashCode ^
        action.hashCode ^
        targetCO2Savings.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        created_at.hashCode;
  }
}
