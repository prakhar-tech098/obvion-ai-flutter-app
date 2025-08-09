part of 'gallery_cubit.dart';

enum GalleryStatus { initial, loading, ready, loadingMore, error }

class GalleryState extends Equatable {
  final GalleryStatus status;
  final List<ImageItem> items;
  final bool hasMore;
  final String? error;

  const GalleryState({
    required this.status,
    required this.items,
    required this.hasMore,
    this.error,
  });

  const GalleryState.initial()
      : this(
    status: GalleryStatus.initial,
    items: const [],
    hasMore: true,
    error: null,
  );

  GalleryState copyWith({
    GalleryStatus? status,
    List<ImageItem>? items,
    bool? hasMore,
    String? error,
  }) {
    return GalleryState(
      status: status ?? this.status,
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, items, hasMore, error];
}