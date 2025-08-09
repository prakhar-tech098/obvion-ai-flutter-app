// lib/domain/usecases/upload_training_images.dart
import '../repositories/photo_repository.dart';

class UploadTrainingImages {
  final PhotoRepository repo;
  UploadTrainingImages(this.repo);

  Future<String> call(List<String> filePaths) async {
    await repo.ensureSession();
    return repo.uploadTrainingZip(filePaths);
  }
}
