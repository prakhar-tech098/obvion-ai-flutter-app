// lib/presentation/widgets/prompt_bar.dart
import 'package:flutter/material.dart';

class PromptBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;
  const PromptBar({super.key, required this.onChanged, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'Describe the photo (e.g., holding a bouquet of roses)',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: onSubmit, child: const Text('Go')),
        ],
      ),
    );
  }
}
