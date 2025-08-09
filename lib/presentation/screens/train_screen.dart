// lib/presentation/screens/train_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/upload_grid.dart';
import '../../presentation/state/training_cubit.dart';
import 'package:image_picker/image_picker.dart';


class TrainScreen extends StatefulWidget {
  const TrainScreen({super.key});

  @override
  State<TrainScreen> createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  final _name = TextEditingController();
  String _type = 'man';
  String _age = 'adult';
  String _ethnicity = 'asian';
  String _eyeColor = 'brown';
  bool _bald = false;
  final _images = <File>[];

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 95);
    if (files != null) {
      setState(() => _images.addAll(files.map((x) => File(x.path))));
    }
  }

  void _startTraining() {
    context.read<TrainingCubit>().startTraining(
      imagePaths: _images.map((f) => f.path).toList(),
      name: _name.text,
      type: _type,
      age: _age,
      ethnicity: _ethnicity,
      eyeColor: _eyeColor,
      bald: _bald,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Train Model')),
      body: BlocConsumer<TrainingCubit, TrainingState>(
        listener: (context, state) {
          if (state.status == TrainingStatus.ready) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Model ready!')));
            Navigator.pop(context, state.modelId);
          } else if (state.status == TrainingStatus.failed) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error ?? 'Failed')));
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(controller: _name, decoration: const InputDecoration(labelText: 'Model Name')),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'man', child: Text('Man')),
                  DropdownMenuItem(value: 'woman', child: Text('Woman')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => _type = v as String),
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                value: _age,
                items: const [
                  DropdownMenuItem(value: 'teen', child: Text('Teen')),
                  DropdownMenuItem(value: 'adult', child: Text('Adult')),
                  DropdownMenuItem(value: 'senior', child: Text('Senior')),
                ],
                onChanged: (v) => setState(() => _age = v as String),
                decoration: const InputDecoration(labelText: 'Age'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                value: _ethnicity,
                items: const [
                  DropdownMenuItem(value: 'asian', child: Text('Asian')),
                  DropdownMenuItem(value: 'white', child: Text('White')),
                  DropdownMenuItem(value: 'black', child: Text('Black')),
                  DropdownMenuItem(value: 'hispanic', child: Text('Hispanic')),
                ],
                onChanged: (v) => setState(() => _ethnicity = v as String),
                decoration: const InputDecoration(labelText: 'Ethnicity'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                value: _eyeColor,
                items: const [
                  DropdownMenuItem(value: 'brown', child: Text('Brown')),
                  DropdownMenuItem(value: 'blue', child: Text('Blue')),
                  DropdownMenuItem(value: 'green', child: Text('Green')),
                  DropdownMenuItem(value: 'hazel', child: Text('Hazel')),
                  DropdownMenuItem(value: 'gray', child: Text('Gray')),
                ],
                onChanged: (v) => setState(() => _eyeColor = v as String),
                decoration: const InputDecoration(labelText: 'Eye Color'),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Bald'),
                value: _bald,
                onChanged: (v) => setState(() => _bald = v),
              ),
              const SizedBox(height: 12),
              UploadGrid(files: _images, onAddPressed: _pickImages),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: state.status == TrainingStatus.uploading || state.status == TrainingStatus.training || _images.length < 10
                    ? null
                    : _startTraining,
                child: Text(
                  state.status == TrainingStatus.uploading
                      ? 'Uploading...'
                      : state.status == TrainingStatus.training || state.status == TrainingStatus.waiting
                      ? 'Training...'
                      : 'Start Training',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
