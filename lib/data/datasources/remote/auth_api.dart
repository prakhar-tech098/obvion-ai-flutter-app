// lib/data/datasources/remote/auth_api.dart
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class AuthApi {
  final ApiClient _client;
  AuthApi(this._client);

  Future<String> signInAnonymously() async {
    // Your backend should provide a session endpoint that returns a JWT compatible with its auth
    final res = await _client.dio.post('/auth/session/anonymous');
    return res.data['token'] as String;
  }
}
