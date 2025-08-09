// lib/presentation/state/training_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/upload_training_images.dart';
import '../../domain/usecases/train_model.dart';

part 'training_state.dart';

class TrainingCubit extends Cubit<TrainingState> {
  final UploadTrainingImages uploadTrainingImages;
  final TrainModel trainModel;

  TrainingCubit({required this.uploadTrainingImages, required this.trainModel})
      : super(const TrainingState.initial());

  Future<void> startTraining({
    required List<String> imagePaths,
    required String name,
    required String type,
    required String age,
    required String ethnicity,
    required String eyeColor,
    required bool bald,
  }) async {
    try {
      emit(state.copyWith(status: TrainingStatus.uploading));
      final zipUrl = await uploadTrainingImages(imagePaths);
      emit(state.copyWith(status: TrainingStatus.training));
      final modelId = await trainModel.start(
        name: name, type: type, age: age, ethnicity: ethnicity, eyeColor: eyeColor, bald: bald, zipUrl: zipUrl,
      );
      emit(state.copyWith(status: TrainingStatus.waiting, modelId: modelId));
      await trainModel.waitUntilReady(modelId);
      emit(state.copyWith(status: TrainingStatus.ready, modelId: modelId));
    } catch (e) {
      emit(state.copyWith(status: TrainingStatus.failed, error: e.toString()));
    }
  }
}
