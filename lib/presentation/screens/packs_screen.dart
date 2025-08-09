import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/di/service_locator.dart';
import '../../domain/entities/pack_entity.dart';
import '../../domain/usecases/fetch_packs.dart';
import '../../domain/usecases/generate_images.dart';

class PacksScreen extends StatefulWidget {
  final String modelId; // Pass the trained modelId
  const PacksScreen({super.key, required this.modelId});

  @override
  State<PacksScreen> createState() => _PacksScreenState();
}

class _PacksScreenState extends State<PacksScreen> {
  late final FetchPacks _fetchPacks;
  late final GenerateImages _generateImages;

  List<PackEntity> _packs = const [];
  bool _loading = true;
  String? _error;
  String? _runningPackId;

  @override
  void initState() {
    super.initState();
    _fetchPacks = sl<FetchPacks>();
    _generateImages = sl<GenerateImages>();
    _loadPacks();
  }

  Future<void> _loadPacks() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final packs = await _fetchPacks.call();
      if (!mounted) return;
      setState(() {
        _packs = packs;
        _loading = false; // fixed: was "loading"
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load packs. Please try again.';
        _loading = false;
      });
    }
  }

  Future<void> _runPack(PackEntity pack) async {
    if (_runningPackId != null) return;
    setState(() => _runningPackId = pack.id);

    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting "${pack.title}"…')),
    );

    try {
      await _generateImages.byPack(modelId: widget.modelId, packId: pack.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${pack.title}" started. Check Gallery soon.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start "${pack.title}".')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _runningPackId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _buildBody();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Packs'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadPacks,
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

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _loadPacks,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }
    if (_packs.isEmpty) {
      return const Center(child: Text('No packs available right now.'));
    }

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 900 ? 4 : width > 600 ? 3 : 2;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _packs.length,
      itemBuilder: (_, i) {
        final p = _packs[i];
        final running = _runningPackId == p.id;
        return _PackCard(
          pack: p,
          running: running,
          onRun: () => _runPack(p),
        );
      },
    );
  }
}

class _PackCard extends StatelessWidget {
  final PackEntity pack;
  final VoidCallback onRun;
  final bool running;

  const _PackCard({
    required this.pack,
    required this.onRun,
    required this.running,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: running ? null : onRun,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.collections_bookmark_outlined, color: Colors.white70),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pack.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  pack.description,
                  style: const TextStyle(color: Colors.white70),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('${pack.promptsCount} prompts', style: const TextStyle(fontSize: 12)),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: running ? null : onRun,
                    icon: running
                        ? const SizedBox(
                      width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.play_arrow_rounded),
                    label: Text(running ? 'Starting…' : 'Run'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
