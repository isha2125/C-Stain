// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ParticipationModel {
  final String participationId;
  final String campaignId;
  final String userId;
  final Timestamp joinedAt;
  final double? carbonSaved;
  final List<String>? contributionIds;
  ParticipationModel({
    required this.participationId,
    required this.campaignId,
    required this.userId,
    required this.joinedAt,
    this.carbonSaved,
    this.contributionIds,
  });

  ParticipationModel copyWith({
    String? participationId,
    String? campaignId,
    String? userId,
    Timestamp? joinedAt,
    double? carbonSaved,
    List<String>? contributionIds,
  }) {
    return ParticipationModel(
      participationId: participationId ?? this.participationId,
      campaignId: campaignId ?? this.campaignId,
      userId: userId ?? this.userId,
      joinedAt: joinedAt ?? this.joinedAt,
      carbonSaved: carbonSaved ?? this.carbonSaved,
      contributionIds: contributionIds ?? this.contributionIds,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'participationId': participationId,
      'campaignId': campaignId,
      'userId': userId,
      'joinedAt': joinedAt,
      'carbonSaved': carbonSaved,
      'contributionIds': contributionIds,
    };
  }

  factory ParticipationModel.fromMap(Map<String, dynamic> map) {
    return ParticipationModel(
      participationId: map['participationId'] as String,
      campaignId: map['campaignId'] as String,
      userId: map['userId'] as String,
      joinedAt: map['joinedAt'] as Timestamp,
      carbonSaved:
          map['carbonSaved'] != null ? map['carbonSaved'] as double : null,
      contributionIds: map['contributionIds'] != null
          ? List<String>.from(
              (map['contributionIds'] as List<dynamic>)
                  .map((e) => e.toString()),
            )
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory ParticipationModel.fromJson(String source) =>
      ParticipationModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ParticipationModel(participationId: $participationId, campaignId: $campaignId, userId: $userId, joinedAt: $joinedAt, carbonSaved: $carbonSaved, contributionIds: $contributionIds)';
  }

  @override
  bool operator ==(covariant ParticipationModel other) {
    if (identical(this, other)) return true;

    return other.participationId == participationId &&
        other.campaignId == campaignId &&
        other.userId == userId &&
        other.joinedAt == joinedAt &&
        other.carbonSaved == carbonSaved &&
        listEquals(other.contributionIds, contributionIds);
  }

  @override
  int get hashCode {
    return participationId.hashCode ^
        campaignId.hashCode ^
        userId.hashCode ^
        joinedAt.hashCode ^
        carbonSaved.hashCode ^
        contributionIds.hashCode;
  }
}
