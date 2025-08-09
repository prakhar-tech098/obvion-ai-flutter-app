// lib/data/datasources/remote/s3_upload.dart
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../env.dart';

class S3Uploader {
  final Dio _dio = Dio();

  Future<String> uploadZip(File file, {required String objectKey}) async {
    if (Env.s3UploadUrl.isEmpty) {
      throw Exception('S3 upload URL not configured');
    }

    final formData = FormData.fromMap({
      'key': objectKey,
      'file': await MultipartFile.fromFile(
        file.path,
        filename: objectKey, // e.g., train_123.zip
      ),
      'bucket': Env.s3UploadBucket,
      'apiKey': Env.s3UploadKey,
    });

    final res = await _dio.post(
      Env.s3UploadUrl,
      data: formData,
      // Dio will set Content-Type: multipart/form-data; boundary=...
    );

    if (res.statusCode == 200 && res.data is Map && res.data['url'] != null) {
      return res.data['url'] as String;
    }
    throw Exception('Upload failed: ${res.statusCode} ${res.data}');
  }
}
