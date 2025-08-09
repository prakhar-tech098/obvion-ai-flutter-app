import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:untitled/authentication_screens/splashscreen.dart';
import 'core/api/auth_provider.dart';
import 'core/di/service_locator.dart';

// If you have a central routes file, import it.
// Update the path to match your project if different.
// Example: lib/presentation/routes.dart with class Routes { static Route<dynamic> onGenerateRoute(...) }
import 'presentation/routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize your service locator
  await setupLocator();

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'My App',
        theme: ThemeData(
          // Define your theme here
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF7C4DFF),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),

        // Keep SplashScreen as the entry point
        home: const SplashScreen(),

        // Optional but recommended: enable named routing for later navigation
        navigatorKey: navigatorKey,
        onGenerateRoute: Routes.onGenerateRoute, // ensure your Routes file provides this
      ),
    );
  }
}
