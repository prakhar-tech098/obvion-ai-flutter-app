// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generated_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneratedImage _$GeneratedImageFromJson(Map<String, dynamic> json) =>
    GeneratedImage(
      id: json['id'] as String,
      url: json['url'] as String,
      prompt: json['prompt'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$GeneratedImageToJson(GeneratedImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'prompt': instance.prompt,
      'status': instance.status,
    };
