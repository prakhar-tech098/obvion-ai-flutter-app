import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/usecases/fetch_packs.dart';
import '../../domain/usecases/generate_images.dart';
import '../../domain/entities/pack_entity.dart';

part 'packs_state.dart';

class PacksCubit extends Cubit<PacksState> {
  final FetchPacks fetchPacks;
  final GenerateImages generateImages;

  PacksCubit({
    required this.fetchPacks,
    required this.generateImages,
  }) : super(const PacksState.initial());

  Future<void> load() async {
    emit(state.copyWith(status: PacksStatus.loading, error: null));
    try {
      final packs = await fetchPacks.call();
      emit(state.copyWith(status: PacksStatus.ready, packs: packs));
    } catch (e) {
      emit(state.copyWith(status: PacksStatus.error, error: 'Failed to load packs'));
    }
  }

  Future<void> runPack({required String modelId, required String packId}) async {
    if (state.runningPackId != null) return;
    emit(state.copyWith(runningPackId: packId));
    try {
      await generateImages.byPack(modelId: modelId, packId: packId);
      emit(state.copyWith(runningPackId: null));
    } catch (e) {
      emit(state.copyWith(runningPackId: null, error: 'Failed to start pack'));
    }
  }
}

