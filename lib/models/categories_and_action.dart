// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

//import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesAndActionModel {
  final String? action_name;
  final String? category_name;
  final double? co2_saving_factor;
  CategoriesAndActionModel({
    this.action_name,
    this.category_name,
    this.co2_saving_factor,
  });

  CategoriesAndActionModel copyWith({
    String? action_name,
    String? category_name,
    double? co2_saving_factor,
  }) {
    return CategoriesAndActionModel(
      action_name: action_name ?? this.action_name,
      category_name: category_name ?? this.category_name,
      co2_saving_factor: co2_saving_factor ?? this.co2_saving_factor,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'action_name': action_name,
      'category_name': category_name,
      'co2_saving_factor': co2_saving_factor,
    };
  }

  factory CategoriesAndActionModel.fromMap(Map<String, dynamic> map) {
    return CategoriesAndActionModel(
      action_name:
          map['action_name'] != null ? map['action_name'] as String : null,
      category_name:
          map['category_name'] != null ? map['category_name'] as String : null,
      co2_saving_factor: map['co2_saving_factor'] is int
          ? (map['co2_saving_factor'] as int).toDouble()
          : map['co2_saving_factor'],
    );
  }

  String toJson() => json.encode(toMap());

  factory CategoriesAndActionModel.fromJson(String source) =>
      CategoriesAndActionModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'CategoriesAndActionModel(action_name: $action_name, category_name: $category_name, co2_saving_factor: $co2_saving_factor)';

  @override
  bool operator ==(covariant CategoriesAndActionModel other) {
    if (identical(this, other)) return true;

    return other.action_name == action_name &&
        other.category_name == category_name &&
        other.co2_saving_factor == co2_saving_factor;
  }

  @override
  int get hashCode =>
      action_name.hashCode ^
      category_name.hashCode ^
      co2_saving_factor.hashCode;
}
