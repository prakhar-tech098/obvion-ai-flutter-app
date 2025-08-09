// lib/domain/usecases/generate_images.dart
import '../entities/image_item.dart';
import '../repositories/photo_repository.dart';

class GenerateImages {
  final PhotoRepository repo;
  GenerateImages(this.repo);

  Future<List<ImageItem>> byPrompt({required String modelId, required String prompt, int count = 2}) async {
    await repo.ensureSession();
    final jobId = await repo.startGeneration(modelId: modelId, prompt: prompt, count: count);
    return repo.pollGenerationResult(jobId);
  }

  Future<void> byPack({required String modelId, required String packId}) async {
    await repo.ensureSession();
    await repo.generatePack(modelId: modelId, packId: packId);
  }
}
