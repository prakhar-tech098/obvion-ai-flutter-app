// lib/data/datasources/remote/photo_api.dart
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class PhotoApi {
  final ApiClient _client;
  PhotoApi(this._client);

  // 1) Start training with zip URL and metadata
  Future<Map<String, dynamic>> startTraining({
    required String name,
    required String type,
    required String age,
    required String ethnicity,
    required String eyeColor,
    required bool bald,
    required String zipUrl,
  }) async {
    final res = await _client.dio.post('/ai/train', data: {
      'name': name,
      'type': type,
      'age': age,
      'ethnicity': ethnicity,
      'eyeColor': eyeColor,
      'bald': bald,
      'zipUrl': zipUrl,
    });
    return res.data as Map<String, dynamic>;
  }

  // 2) Poll model status
  Future<Map<String, dynamic>> getModelStatus(String modelId) async {
    final res = await _client.dio.get('/ai/model/$modelId/status');
    return res.data as Map<String, dynamic>;
  }

  // 3) Generate images
  Future<Map<String, dynamic>> generate({
    required String modelId,
    required String prompt,
    required int count,
  }) async {
    final res = await _client.dio.post('/ai/generate', data: {
      'modelId': modelId,
      'prompt': prompt,
      'count': count,
    });
    return res.data as Map<String, dynamic>;
  }

  // 4) Poll image job status
  Future<Map<String, dynamic>> getImageJob(String jobId) async {
    final res = await _client.dio.get('/image/$jobId');
    return res.data as Map<String, dynamic>;
  }

  // 5) Packs
  Future<List<dynamic>> getPacks() async {
    final res = await _client.dio.get('/packs');
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> generatePack({
    required String modelId,
    required String packId,
  }) async {
    final res = await _client.dio.post('/packs/generate', data: {
      'modelId': modelId,
      'packId': packId,
    });
    return res.data as Map<String, dynamic>;
  }

  // 6) Gallery pagination
  Future<Map<String, dynamic>> getImages({required int limit, required int offset}) async {
    final res = await _client.dio.get('/images', queryParameters: {'limit': limit, 'offset': offset});
    return res.data as Map<String, dynamic>;
  }
}
