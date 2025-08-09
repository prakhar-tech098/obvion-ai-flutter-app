// lib/data/models/pack.dart
import 'package:json_annotation/json_annotation.dart';
part 'pack.g.dart';

@JsonSerializable()
class PackModel {
  final String id;
  final String title;
  final String description;
  final int promptsCount;
  PackModel({required this.id, required this.title, required this.description, required this.promptsCount});
  factory PackModel.fromJson(Map<String, dynamic> json) => _$PackModelFromJson(json);
  Map<String, dynamic> toJson() => _$PackModelToJson(this);
}
