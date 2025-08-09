import 'package:flutter/material.dart';


import 'package:untitled/presentation/screens/home_screen.dart';
import 'package:untitled/presentation/screens/train_screen.dart';
import 'package:untitled/presentation/screens/generate_screen.dart';
import 'package:untitled/presentation/screens/packs_screen.dart';
import 'package:untitled/presentation/screens/gallery_screen.dart';

import '../authentication_screens/splashscreen.dart';

class Routes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const train = '/train';
  static const generate = '/generate';
  static const packs = '/packs';
  static const gallery = '/gallery';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      // case login:
      //   return MaterialPageRoute(builder: (_) => const SignInScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case train:
        return MaterialPageRoute(builder: (_) => const TrainScreen());
      case generate:
        final args = settings.arguments as Map<String, dynamic>?; // expects {'modelId': '...'}
        final modelId = args?['modelId'] as String? ?? '';
        return MaterialPageRoute(builder: (_) => GenerateScreen(modelId: modelId));
      case packs:
        return MaterialPageRoute(builder: (_) => const PacksScreen(modelId: '',));
      case gallery:
        return MaterialPageRoute(builder: (_) => const GalleryScreen());
       default:
       return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('Route not found'))),
         );
    }
  }
}
