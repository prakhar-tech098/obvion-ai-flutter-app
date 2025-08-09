// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pack.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PackModel _$PackModelFromJson(Map<String, dynamic> json) => PackModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      promptsCount: (json['promptsCount'] as num).toInt(),
    );

Map<String, dynamic> _$PackModelToJson(PackModel instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'promptsCount': instance.promptsCount,
    };
