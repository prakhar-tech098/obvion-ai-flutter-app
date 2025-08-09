// lib/domain/entities/pack_entity.dart
class PackEntity {
  final String id;
  final String title;
  final String description;
  final int promptsCount;
  PackEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.promptsCount,
  });
}
