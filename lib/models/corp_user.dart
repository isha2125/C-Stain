// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:ffi';

class CorpUserModel {
  final String userId;
  final String name;
  final String type;
  final String size;
  final String goal;
  CorpUserModel({
    required this.userId,
    required this.name,
    required this.type,
    required this.size,
    required this.goal,
  });

  CorpUserModel copyWith({
    String? userId,
    String? name,
    String? type,
    String? size,
    String? goal,
  }) {
    return CorpUserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      size: size ?? this.size,
      goal: goal ?? this.goal,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'name': name,
      'type': type,
      'size': size,
      'goal': goal,
    };
  }

  factory CorpUserModel.fromMap(Map<String, dynamic> map) {
    return CorpUserModel(
      userId: map['userId'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      size: map['size'] as String,
      goal: map['goal'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CorpUserModel.fromJson(String source) =>
      CorpUserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CorpUserModel(userId: $userId, name: $name, type: $type, size: $size, goal: $goal)';
  }

  @override
  bool operator ==(covariant CorpUserModel other) {
    if (identical(this, other)) return true;

    return other.userId == userId &&
        other.name == name &&
        other.type == type &&
        other.size == size &&
        other.goal == goal;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        name.hashCode ^
        type.hashCode ^
        size.hashCode ^
        goal.hashCode;
  }
}
