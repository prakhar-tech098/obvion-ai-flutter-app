// lib/domain/repositories/photo_repository.dart
import '../entities/ai_model.dart';
import '../entities/image_item.dart';
import '../entities/pack_entity.dart';

abstract class PhotoRepository {
  Future<String> ensureSession();
  Future<String> uploadTrainingZip(List<String> filePaths);
  Future<String> startTraining({
    required String name,
    required String type,
    required String age,
    required String ethnicity,
    required String eyeColor,
    required bool bald,
    required String zipUrl,
  });
  Future<String> pollModelReady(String modelId);
  Future<String> startGeneration({required String modelId, required String prompt, required int count});
  Future<List<ImageItem>> pollGenerationResult(String jobId);
  Future<List<PackEntity>> getPacks();
  Future<void> generatePack({required String modelId, required String packId});
  Future<List<ImageItem>> getImages({required int limit, required int offset});
}
