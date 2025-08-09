// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_training.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModelTrainingResponse _$ModelTrainingResponseFromJson(
        Map<String, dynamic> json) =>
    ModelTrainingResponse(
      modelId: json['modelId'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$ModelTrainingResponseToJson(
        ModelTrainingResponse instance) =>
    <String, dynamic>{
      'modelId': instance.modelId,
      'status': instance.status,
    };
