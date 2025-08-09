// lib/presentation/widgets/upload_grid.dart
import 'dart:io';
import 'package:flutter/material.dart';

class UploadGrid extends StatelessWidget {
  final List<File> files;
  final VoidCallback onAddPressed;
  const UploadGrid({super.key, required this.files, required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...files.map((f) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(f, height: 100, width: 100, fit: BoxFit.cover),
            )),
            InkWell(
              onTap: onAddPressed,
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.add_a_photo),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('${files.length} selected (min 10 recommended)'),
      ],
    );
  }
}
