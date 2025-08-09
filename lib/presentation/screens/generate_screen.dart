// lib/presentation/screens/generate_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/image_tile.dart';
import '../../core/widgets/prompt_bar.dart';
import '../state/generate_cubit.dart';



class GenerateScreen extends StatefulWidget {
  final String modelId;
  const GenerateScreen({super.key, required this.modelId});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  String _prompt = '';

  void _onGenerate() {
    if (_prompt.isNotEmpty) {
      context.read<GenerateCubit>().generatePrompt(modelId: widget.modelId, prompt: _prompt, count: 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate')),
      body: Column(
        children: [
          PromptBar(onChanged: (v) => _prompt = v, onSubmit: _onGenerate),
          Expanded(
            child: BlocBuilder<GenerateCubit, GenerateState>(
              builder: (context, state) {
                if (state.status == GenerateStatus.generating) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == GenerateStatus.ready) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8),
                    itemCount: state.images.length,
                    itemBuilder: (_, i) => ImageTile(url: state.images[i].url),
                  );
                }
                return const Center(child: Text('Enter a prompt to generate'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _onGenerate, child: const Icon(Icons.bolt)),
    );
  }
}
