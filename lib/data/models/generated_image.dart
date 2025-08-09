// lib/data/models/generated_image.dart
import 'package:json_annotation/json_annotation.dart';
part 'generated_image.g.dart';

@JsonSerializable()
class GeneratedImage {
  final String id;
  final String url;
  final String prompt;
  final String status; // queued, generating, ready, failed
  GeneratedImage({required this.id, required this.url, required this.prompt, required this.status});
  factory GeneratedImage.fromJson(Map<String, dynamic> json) => _$GeneratedImageFromJson(json);
  Map<String, dynamic> toJson() => _$GeneratedImageToJson(this);
}
