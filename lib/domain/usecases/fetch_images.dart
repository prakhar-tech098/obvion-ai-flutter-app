// lib/domain/usecases/fetch_images.dart
import '../entities/image_item.dart';
import '../repositories/photo_repository.dart';

class FetchImages {
  final PhotoRepository repo;
  FetchImages(this.repo);

  Future<List<ImageItem>> call({int limit = 20, int offset = 0}) async {
    await repo.ensureSession();
    return repo.getImages(limit: limit, offset: offset);
  }
}
