// lib/presentation/state/generate_state.dart
part of 'generate_cubit.dart';

enum GenerateStatus { initial, generating, ready, failed }

class GenerateState extends Equatable {
  final GenerateStatus status;
  final List<ImageItem> images;
  final String? error;
  const GenerateState({required this.status, required this.images, this.error});
  const GenerateState.initial() : this(status: GenerateStatus.initial, images: const []);

  GenerateState copyWith({GenerateStatus? status, List<ImageItem>? images, String? error}) {
    return GenerateState(status: status ?? this.status, images: images ?? this.images, error: error ?? this.error);
  }

  @override
  List<Object?> get props => [status, images, error];
}
