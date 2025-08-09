// lib/env.dart
class Env {
  // Backend base URL (Express backend)
  // Override at runtime:
  // flutter run --dart-define=BACKEND_BASE_URL=https://your-backend.example.com
  static const backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'https://api.photoaiv2.100xdevs.com',
  );

  // Use backend-issued session tokens (anonymous or Clerk-proxied)
  static const useBackendSession = bool.fromEnvironment(
    'USE_BACKEND_SESSION',
    defaultValue: true,
  );

  // If true, client uploads training zip directly to object storage.
  // If false, the app will POST images/zip to your backend instead.
  static const directUploadEnabled = bool.fromEnvironment(
    'DIRECT_UPLOAD_ENABLED',
    defaultValue: false,
  );

  // Object storage / presigned upload config (used only if directUploadEnabled=true)
  // For presigned PUT flows, set S3_PRESIGNED_PUT to a complete URL
  // and leave s3UploadUrl empty. For form-based uploads, set s3UploadUrl to your
  // backend/form endpoint and supply bucket/key as required by your server.
  static const s3UploadUrl = String.fromEnvironment('S3_UPLOAD_URL', defaultValue: '');
  static const s3PresignedPut = String.fromEnvironment('S3_PRESIGNED_PUT', defaultValue: '');
  static const s3UploadBucket = String.fromEnvironment('S3_UPLOAD_BUCKET', defaultValue: '');
  static const s3UploadKey = String.fromEnvironment('S3_UPLOAD_KEY', defaultValue: '');

  // Polling intervals/timeouts (override without code changes)
  static const pollIntervalMs = int.fromEnvironment('POLL_INTERVAL_MS', defaultValue: 2000);
  static const inferenceTimeoutMs = int.fromEnvironment('INFERENCE_TIMEOUT_MS', defaultValue: 120000); // 2 minutes
  static const trainingTimeoutMs = int.fromEnvironment('TRAINING_TIMEOUT_MS', defaultValue: 1800000); // 30 minutes

  // Feature flags
  static const enablePacks = bool.fromEnvironment('ENABLE_PACKS', defaultValue: true);

  // Optional logging flag for network layer
  static const enableNetworkLogging = bool.fromEnvironment('ENABLE_NETWORK_LOGGING', defaultValue: true);

  // Convenience: computed booleans
  static bool get isDirectFormUpload => directUploadEnabled && s3UploadUrl.isNotEmpty;
  static bool get isDirectPutUpload => directUploadEnabled && s3PresignedPut.isNotEmpty;
}
