import 'package:flutter/material.dart';

/// A class to hold reusable gradient styles for the application.
/// This can be placed in your `core/theme/app_colors.dart` file or a new `app_gradients.dart`.
class AppGradients {

  /// A dark gradient that transitions from pure black at the top to a very
  /// dark grey at the bottom.
  ///
  /// Perfect for backgrounds to create a subtle, premium dark-themed look.
  static const BoxDecoration darkGradient = BoxDecoration(
    gradient: LinearGradient(
      // The alignment of the gradient start and end points.
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,

      // The list of colors for the gradient.
      // It starts with black and fades to a dark grey (Colors.grey[900]).
      colors: [
        Colors.black,
        Color(0xFF212121),
      ],

      // (Optional) You can define stops to control where the colors transition.
      // For example, `stops: [0.0, 0.8]` would make the black color cover the
      // top 80% of the container, with the fade happening in the last 20%.
      // If left null, the transition is spread evenly.
      stops: [0.2, 0.5],
    ),
  );
}

/*
--- HOW TO USE THIS GRADIENT ---

You can apply this gradient to any widget that accepts a `decoration`,
like a `Container`. To set it as the background for your login screen,
wrap your screen's content in a Container and apply the decoration.

Example for your `login_screen.dart`:

import 'package:flutter/material.dart';
// Make sure to import the file where you placed AppGradients
import 'package:your_project_name/core/theme/app_colors.dart'; // Or wherever you saved it

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Apply the reusable gradient here
        decoration: AppGradients.darkGradient,
        // Ensure the container fills the entire screen
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Text(
            'Your Login Form Goes Here',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

*/
