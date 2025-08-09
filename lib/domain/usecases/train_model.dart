// lib/domain/usecases/train_model.dart
import '../repositories/photo_repository.dart';

class TrainModel {
  final PhotoRepository repo;
  TrainModel(this.repo);

  Future<String> start({
    required String name,
    required String type,
    required String age,
    required String ethnicity,
    required String eyeColor,
    required bool bald,
    required String zipUrl,
  }) async {
    await repo.ensureSession();
    final modelId = await repo.startTraining(
      name: name, type: type, age: age, ethnicity: ethnicity, eyeColor: eyeColor, bald: bald, zipUrl: zipUrl,
    );
    return modelId;
  }

  Future<void> waitUntilReady(String modelId) async {
    await repo.pollModelReady(modelId);
  }
}
