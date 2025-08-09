// lib/data/models/pagination.dart
import 'package:json_annotation/json_annotation.dart';
part 'pagination.g.dart';

@JsonSerializable()
class PaginatedImages {
  final List<dynamic> items;
  final int total;
  final int limit;
  final int offset;
  PaginatedImages({required this.items, required this.total, required this.limit, required this.offset});
  factory PaginatedImages.fromJson(Map<String, dynamic> json) => _$PaginatedImagesFromJson(json);
  Map<String, dynamic> toJson() => _$PaginatedImagesToJson(this);
}
