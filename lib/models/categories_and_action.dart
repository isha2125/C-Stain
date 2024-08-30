// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

//import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesAndActionModel {
  final String action;
  final String category;
  final double co2_saved;
  CategoriesAndActionModel({
    required this.action,
    required this.category,
    required this.co2_saved,
  });

  CategoriesAndActionModel copyWith({
    String? action,
    String? category,
    double? co2_saved,
  }) {
    return CategoriesAndActionModel(
      action: action ?? this.action,
      category: category ?? this.category,
      co2_saved: co2_saved ?? this.co2_saved,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'action': action,
      'category': category,
      'co2_saved': co2_saved,
    };
  }

  factory CategoriesAndActionModel.fromMap(Map<String, dynamic> map) {
    return CategoriesAndActionModel(
      action: map['action'] as String,
      category: map['category'] as String,
      co2_saved: map['co2_saved'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory CategoriesAndActionModel.fromJson(String source) =>
      CategoriesAndActionModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'CategoriesAndActionModel(action: $action, category: $category, co2_saved: $co2_saved)';

  @override
  bool operator ==(covariant CategoriesAndActionModel other) {
    if (identical(this, other)) return true;

    return other.action == action &&
        other.category == category &&
        other.co2_saved == co2_saved;
  }

  @override
  int get hashCode => action.hashCode ^ category.hashCode ^ co2_saved.hashCode;
}
