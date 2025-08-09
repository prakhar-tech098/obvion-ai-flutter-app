// lib/data/models/model_training.dart
import 'package:json_annotation/json_annotation.dart';
part 'model_training.g.dart';

@JsonSerializable()
class ModelTrainingResponse {
  final String modelId;
  final String status; // queued, training, ready, failed
  ModelTrainingResponse({required this.modelId, required this.status});
  factory ModelTrainingResponse.fromJson(Map<String, dynamic> json) => _$ModelTrainingResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ModelTrainingResponseToJson(this);
}
