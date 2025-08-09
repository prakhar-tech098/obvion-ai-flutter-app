// lib/presentation/widgets/image_tile.dart
import 'package:flutter/material.dart';

class ImageTile extends StatelessWidget {
  final String url;
  const ImageTile({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(url, fit: BoxFit.cover),
    );
  }
}
