// lib/data/repositories/photo_repository_impl.dart
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/image_zipper.dart';
import '../../domain/repositories/photo_repository.dart';
import '../datasources/remote/auth_api.dart';
import '../datasources/remote/photo_api.dart';
import '../datasources/local/auth_storage.dart';
import '../datasources/remote/s3_upload.dart';
import '../../domain/entities/ai_model.dart';
import '../../domain/entities/image_item.dart';
import '../../domain/entities/pack_entity.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  final AuthApi authApi;
  final PhotoApi photoApi;
  final AuthStorage authStorage;
  final S3Uploader s3Uploader;

  PhotoRepositoryImpl({
    required this.authApi,
    required this.photoApi,
    required this.authStorage,
    required this.s3Uploader,
  });

  @override
  Future<String> ensureSession() async {
    final token = await authStorage.getToken();
    if (token != null && token.isNotEmpty) return token;
    final newToken = await authApi.signInAnonymously();
    await authStorage.saveToken(newToken);
    return newToken;
  }

  @override
  Future<String> uploadTrainingZip(List<String> filePaths) async {
    final dir = await getTemporaryDirectory();
    final zipPath = p.join(dir.path, 'train_${const Uuid().v4()}.zip');
    final files = filePaths.map((e) => File(e)).toList();
    final zipFile = await zipImages(files, zipPath);
    final objectKey = p.basename(zipFile.path);
    final url = await s3Uploader.uploadZip(zipFile, objectKey: objectKey);
    return url;
  }

  @override
  Future<String> startTraining({
    required String name,
    required String type,
    required String age,
    required String ethnicity,
    required String eyeColor,
    required bool bald,
    required String zipUrl,
  }) async {
    final res = await photoApi.startTraining(
      name: name,
      type: type,
      age: age,
      ethnicity: ethnicity,
      eyeColor: eyeColor,
      bald: bald,
      zipUrl: zipUrl,
    );
    return res['modelId'] as String;
  }

  @override
  Future<String> pollModelReady(String modelId) async {
    final start = DateTime.now();
    while (true) {
      final res = await photoApi.getModelStatus(modelId);
      final status = res['status'] as String;
      if (status == 'ready') return 'ready';
      if (status == 'failed') throw Exception('Training failed');
      if (DateTime.now().difference(start).inMinutes >= 30) {
        throw Exception('Training timeout');
      }
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  @override
  Future<String> startGeneration({required String modelId, required String prompt, required int count}) async {
    final res = await photoApi.generate(modelId: modelId, prompt: prompt, count: count);
    return res['jobId'] as String;
  }

  @override
  Future<List<ImageItem>> pollGenerationResult(String jobId) async {
    final start = DateTime.now();
    while (true) {
      final res = await photoApi.getImageJob(jobId);
      final status = res['status'] as String;
      if (status == 'ready') {
        final images = (res['images'] as List)
            .map((e) => ImageItem(id: e['id'], url: e['url'], prompt: e['prompt']))
            .toList();
        return images;
      }
      if (status == 'failed') throw Exception('Generation failed');
      if (DateTime.now().difference(start).inMinutes >= 2) {
        throw Exception('Generation timeout');
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  @override
  Future<List<PackEntity>> getPacks() async {
    final res = await photoApi.getPacks();
    return res
        .map((e) => PackEntity(id: e['id'], title: e['title'], description: e['description'], promptsCount: e['promptsCount']))
        .cast<PackEntity>()
        .toList();
  }

  @override
  Future<void> generatePack({required String modelId, required String packId}) async {
    await photoApi.generatePack(modelId: modelId, packId: packId);
  }

  @override
  Future<List<ImageItem>> getImages({required int limit, required int offset}) async {
    final res = await photoApi.getImages(limit: limit, offset: offset);
    final items = (res['items'] as List)
        .map((e) => ImageItem(id: e['id'], url: e['url'], prompt: e['prompt']))
        .cast<ImageItem>()
        .toList();
    return items;
  }
}
