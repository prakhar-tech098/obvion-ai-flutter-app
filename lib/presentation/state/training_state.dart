// lib/presentation/state/training_state.dart
part of 'training_cubit.dart';

enum TrainingStatus { initial, uploading, training, waiting, ready, failed }

class TrainingState extends Equatable {
  final TrainingStatus status;
  final String? modelId;
  final String? error;

  const TrainingState({required this.status, this.modelId, this.error});

  const TrainingState.initial() : this(status: TrainingStatus.initial);

  TrainingState copyWith({TrainingStatus? status, String? modelId, String? error}) {
    return TrainingState(
      status: status ?? this.status,
      modelId: modelId ?? this.modelId,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, modelId, error];
}
