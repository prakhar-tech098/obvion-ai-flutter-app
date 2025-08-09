import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../domain/entities/image_item.dart';
import '../../domain/usecases/fetch_images.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  // DI usecase
  late final FetchImages _fetchImages;

  // Paging state
  static const int _pageSize = 24;
  final List<ImageItem> _items = [];
  bool _initialLoading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;

  // Scroll controller for infinite scroll
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchImages = sl<FetchImages>();
    _loadInitial();

    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _initialLoading = true;
      _error = null;
    });
    try {
      final first = await _fetchImages.call(limit: _pageSize, offset: 0);
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(first);
        _hasMore = first.length == _pageSize;
        _initialLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initialLoading = false;
        _error = 'Failed to load images. Please try again.';
      });
    }
  }

  Future<void> _refresh() async {
    try {
      final refreshed = await _fetchImages.call(limit: _pageSize, offset: 0);
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(refreshed);
        _hasMore = refreshed.length == _pageSize;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to refresh images.';
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _initialLoading || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final next = await _fetchImages.call(limit: _pageSize, offset: _items.length);
      if (!mounted) return;
      setState(() {
        _items.addAll(next);
        _hasMore = next.length == _pageSize;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingMore = false;
        // Keep hasMore as-is; user can try to load more again by scrolling/refreshing
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load more images.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _buildBody(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        actions: [
          IconButton(
            onPressed: _initialLoading ? null : _loadInitial,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: body,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_initialLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _loadInitial,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return const Center(child: Text('No images yet. Generate to see results here.'));
    }

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1100
        ? 5
        : width > 900
        ? 4
        : width > 600
        ? 3
        : 2;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final img = _items[index];
                  return _ImageTile(url: img.url, prompt: img.prompt);
                },
                childCount: _items.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _loadingMore
                ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            )
                : (!_hasMore
                ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No more images',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            )
                : const SizedBox.shrink()),
          ),
        ],
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  final String url;
  final String prompt;

  const _ImageTile({required this.url, required this.prompt});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openPreview(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Basic Network image; replace with CachedNetworkImage if desired
            Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator(strokeWidth: 2));
              },
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: Colors.black26,
                child: Center(child: Icon(Icons.broken_image, color: Colors.white54)),
              ),
            ),
            // Optional gradient overlay with prompt snippet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
                child: Text(
                  prompt,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPreview(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (_, __, ___) => _FullScreenPreview(url: url, prompt: prompt),
      ),
    );
  }
}

class _FullScreenPreview extends StatelessWidget {
  final String url;
  final String prompt;

  const _FullScreenPreview({required this.url, required this.prompt});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: Navigator.of(context).pop,
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.95),
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 64, color: Colors.white30),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Text(
                  prompt,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                  tooltip: 'Close',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
