import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:untitled/domain/usecases/upload_training_images.dart';
import 'package:untitled/presentation/screens/generate_screen.dart';
import 'package:untitled/presentation/screens/packs_screen.dart';
import 'package:untitled/presentation/screens/profile.dart';
import 'package:untitled/presentation/screens/train_screen.dart';
import 'package:untitled/presentation/state/gallery_cubit.dart';
import 'package:untitled/presentation/state/generate_cubit.dart';
import 'package:untitled/presentation/state/training_cubit.dart';

import '../../core/api/auth_provider.dart';
import '../../core/di/service_locator.dart';
import '../../domain/usecases/fetch_images.dart';
import '../../domain/usecases/fetch_packs.dart';
import '../../domain/usecases/generate_images.dart';
import '../../domain/usecases/train_model.dart';
import '../state/packs_cubit.dart';
import 'gallery_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _profileImage;
  String _profileName = "Sonam Bajwa";
  String _profileEmail = "heart_Killer@example.com";

  String? _modelId;
  bool _sessionReady = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      setState(() {
        _sessionReady = true;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _sessionReady = false;
        _error = 'Failed to initialize session.';
      });
    }
  }

  Future<void> _openTrain() async {
    final modelId = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => TrainingCubit(
                uploadTrainingImages: sl<UploadTrainingImages>(),
                trainModel: sl<TrainModel>(),
              ),
            ),
          ],
          child: const TrainScreen(),
        ),
      ),
    );
    if (modelId != null && modelId.isNotEmpty) {
      setState(() => _modelId = modelId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Model ready! You can now generate images.')),
        );
      }
    }
  }

  void _openGenerate() {
    if (_modelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Train a model first to generate images.')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => GenerateCubit(generateImages: sl<GenerateImages>()),
          child: GenerateScreen(modelId: _modelId!),
        ),
      ),
    );
  }

  void _openPacks() {
    if (_modelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Train a model first to use packs.')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => PacksCubit(fetchPacks: sl<FetchPacks>(), generateImages: sl<GenerateImages>()),
          child: PacksScreen(modelId: _modelId!),
        ),
      ),
    );
  }

  void _openGallery() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => GalleryCubit(fetchImages: sl<FetchImages>()),
          child: const GalleryScreen(),
        ),
      ),
    );
  }

  void _logout() async {
    final auth = context.read<AuthProvider>();
    await auth.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _openProfile() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => ProfileScreen(
        initialName: _profileName,
        initialEmail: _profileEmail,
        // initialImage: _profileImage,
      )),
    );

    if (result != null) {
      setState(() {
        _profileName = result['name'] ?? _profileName;
        _profileEmail = result['email'] ?? _profileEmail;
        _profileImage = result['image'] ?? _profileImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tiles = <_ActionTile>[
      _ActionTile(
        icon: Icons.school_outlined,
        title: 'Train Model',
        subtitle: 'Upload 10–20 photos and train',
        color: const Color(0xFF7C4DFF),
        onTap: _openTrain,
      ),
      _ActionTile(
        icon: Icons.bolt_outlined,
        title: 'Generate',
        subtitle: _modelId == null ? 'Train first to unlock' : 'Create images from prompts',
        color: const Color(0xFFE040FB),
        onTap: _openGenerate,
        disabled: _modelId == null,
      ),
      _ActionTile(
        icon: Icons.collections_bookmark_outlined,
        title: 'Packs',
        subtitle: _modelId == null ? 'Train first to unlock' : 'Run themed prompt batches',
        color: const Color(0xFF00E5FF),
        onTap: _openPacks,
        disabled: _modelId == null,
      ),
      _ActionTile(
        icon: Icons.photo_library_outlined,
        title: 'Gallery',
        subtitle: 'Browse your generated images',
        color: const Color(0xFF69F0AE),
        onTap: _openGallery,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Obvion.ai'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(
                      initialName: "Sonam Bajwa",
                      initialEmail: "heart_Killer.com",
                      initialImagePath: _profileImage?.path,
                    ),
                  ),
                ).then((updatedData) {
                  if (updatedData != null) {
                    setState(() {
                      final imagePath = updatedData['imagePath'];
                      _profileImage = (imagePath != null) ? File(imagePath) : null;
                    });
                  }
                });
              },
              child: CircleAvatar(
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : const AssetImage('assets/test.png')
                as ImageProvider,
                radius: 18,
              ),
            ),
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_profileName),
              accountEmail: Text(_profileEmail),
              currentAccountPicture: GestureDetector(
                onTap: _openProfile,
                child: CircleAvatar(
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : const AssetImage('assets/test.png') as ImageProvider,
                ),
              ),
              decoration: const BoxDecoration(color: Colors.deepPurple),
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text("Train Model"),
              onTap: () {
                Navigator.pop(context);
                _openTrain();
              },
            ),
            ListTile(
              leading: const Icon(Icons.bolt),
              title: const Text("Generate"),
              onTap: () {
                Navigator.pop(context);
                _openGenerate();
              },
            ),
            ListTile(
              leading: const Icon(Icons.collections_bookmark),
              title: const Text("Packs"),
              onTap: () {
                Navigator.pop(context);
                _openPacks();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                _openGallery();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(
                      initialName: "Sonam Bajwa",  // Replace with actual user data if you have it
                      initialEmail: "heart_Killer@example.com",
                      initialImagePath: _profileImage?.path,
                    ),
                  ),
                ).then((updatedData) {
                  if (updatedData != null) {
                    setState(() {
                      final imagePath = updatedData['imagePath'];
                      _profileImage = (imagePath != null) ? File(imagePath) : null;
                      // You can add storing name/email here if you want to show them somewhere
                      // For example:
                      // _userName = updatedData['name'];
                      // _userEmail = updatedData['email'];
                    });
                  }
                });
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
      body: _buildBody(tiles),
    );
  }

  Widget _buildBody(List<_ActionTile> tiles) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.redAccent),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (!_sessionReady) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _modelId == null
            ? _InfoCard(
          title: 'Get Started',
          message: 'Begin by training a model with your photos.',
          color: Colors.white10,
        )
            : _InfoCard(
          title: 'Model Ready',
          message: 'Model ID: $_modelId\nYou can now generate images or run packs.',
          color: Colors.white10,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: tiles.map((t) => _FeatureCard(tile: t)).toList(),
        ),
      ],
    );
  }
}

class _ActionTile {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool disabled;

  _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.disabled = false,
  });
}

class _FeatureCard extends StatelessWidget {
  final _ActionTile tile;
  const _FeatureCard({required this.tile});

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2,
      constraints: const BoxConstraints(minWidth: 160, maxWidth: 320, minHeight: 120),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tile.disabled ? Colors.white12 : Colors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(tile.icon, color: tile.color, size: 28),
          const SizedBox(height: 12),
          Text(
            tile.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            tile.subtitle,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );

    if (tile.disabled) {
      return Opacity(opacity: 0.6, child: content);
    }
    return InkWell(onTap: tile.onTap, borderRadius: BorderRadius.circular(16), child: content);
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String message;
  final Color color;

  const _InfoCard({required this.title, required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(message, style: const TextStyle(color: Colors.white70)),
      ]),
    );
  }
}
