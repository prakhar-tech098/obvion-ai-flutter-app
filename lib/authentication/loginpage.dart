import 'package:flutter/material.dart';

import '../core/theme/app_color.dart';

class Loginpage extends StatelessWidget {
  const Loginpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     body: Container(
       decoration:  AppGradients.darkGradient,
         // Ensure the container fills the entire screen
         width: double.infinity,
         height: double.infinity,
     ),
    );
  }
}
