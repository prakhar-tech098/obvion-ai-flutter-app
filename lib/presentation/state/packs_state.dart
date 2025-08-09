part of 'packs_cubit.dart';

enum PacksStatus { initial, loading, ready, error }

class PacksState extends Equatable {
  final PacksStatus status;
  final List<PackEntity> packs;
  final String? error;
  final String? runningPackId;

  const PacksState({
    required this.status,
    required this.packs,
    this.error,
    this.runningPackId,
  });

  const PacksState.initial()
      : this(status: PacksStatus.initial, packs: const []);

  PacksState copyWith({
    PacksStatus? status,
    List<PackEntity>? packs,
    String? error,
    String? runningPackId,
  }) {
    return PacksState(
      status: status ?? this.status,
      packs: packs ?? this.packs,
      error: error ?? this.error,
      runningPackId: runningPackId,
    );
  }

  @override
  List<Object?> get props => [status, packs, error, runningPackId];
}