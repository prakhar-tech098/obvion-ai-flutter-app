// lib/core/di/service_locator.dart
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../../data/datasources/remote/auth_api.dart';
import '../../data/datasources/remote/photo_api.dart';
import '../../data/datasources/local/auth_storage.dart';
import '../../data/datasources/remote/s3_upload.dart';
import '../../data/repositories/photo_repository_impl.dart';
import '../../domain/repositories/photo_repository.dart';
import '../../domain/usecases/fetch_images.dart';
import '../../domain/usecases/fetch_packs.dart';
import '../../domain/usecases/generate_images.dart';
import '../../domain/usecases/train_model.dart';
import '../../domain/usecases/upload_training_images.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // Network
  final dio = Dio();
  sl.registerLazySingleton<Dio>(() => dio);
  sl.registerLazySingleton<ApiClient>(() => ApiClient(dio));

  // Storage
  sl.registerLazySingleton<AuthStorage>(() => AuthStorage());

  // Remote APIs
  sl.registerLazySingleton<AuthApi>(() => AuthApi(sl<ApiClient>()));
  sl.registerLazySingleton<PhotoApi>(() => PhotoApi(sl<ApiClient>()));
  sl.registerLazySingleton<S3Uploader>(() => S3Uploader());

  // Repository
  sl.registerLazySingleton<PhotoRepository>(() => PhotoRepositoryImpl(
    authApi: sl<AuthApi>(),
    photoApi: sl<PhotoApi>(),
    authStorage: sl<AuthStorage>(),
    s3Uploader: sl<S3Uploader>(),
  ));

  // Usecases
  sl.registerFactory(() => UploadTrainingImages(sl<PhotoRepository>()));
  sl.registerFactory(() => TrainModel(sl<PhotoRepository>()));
  sl.registerFactory(() => GenerateImages(sl<PhotoRepository>()));
  sl.registerFactory(() => FetchImages(sl<PhotoRepository>()));
  sl.registerFactory(() => FetchPacks(sl<PhotoRepository>()));
}
