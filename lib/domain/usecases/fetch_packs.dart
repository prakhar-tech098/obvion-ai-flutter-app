// lib/domain/usecases/fetch_packs.dart
import '../entities/pack_entity.dart';
import '../repositories/photo_repository.dart';

class FetchPacks {
  final PhotoRepository repo;
  FetchPacks(this.repo);

  Future<List<PackEntity>> call() async {
    await repo.ensureSession();
    return repo.getPacks();
  }
}
