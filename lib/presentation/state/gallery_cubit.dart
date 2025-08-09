import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/image_item.dart';
import '../../domain/usecases/fetch_images.dart';

part 'gallery_state.dart';

class GalleryCubit extends Cubit<GalleryState> {
  final FetchImages fetchImages;
  static const int pageSize = 24;

  GalleryCubit({required this.fetchImages})
      : super(const GalleryState.initial());

  Future<void> loadInitial() async {
    emit(state.copyWith(
      status: GalleryStatus.loading,
      error: null,
      items: const [],
      hasMore: true,
    ));
    try {
      final items = await fetchImages.call(limit: pageSize, offset: 0);
      emit(state.copyWith(
        status: GalleryStatus.ready,
        items: items,
        hasMore: items.length == pageSize,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GalleryStatus.error,
        error: 'Failed to load images.',
      ));
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.status == GalleryStatus.loadingMore) return;
    emit(state.copyWith(status: GalleryStatus.loadingMore));
    try {
      final next = await fetchImages.call(
        limit: pageSize,
        offset: state.items.length,
      );
      emit(state.copyWith(
        status: GalleryStatus.ready,
        items: [...state.items, ...next],
        hasMore: next.length == pageSize,
      ));
    } catch (e) {
// Keep current list; just stop loadingMore
      emit(state.copyWith(status: GalleryStatus.ready));
    }
  }
}