import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import firebase_core package
import 'package:furmate/screens/home.dart';
import 'package:furmate/screens/pet_list.dart';
import 'package:furmate/screens/settings.dart';
import 'firebase_options.dart'; // Import the generated firebase_options.dart file
import 'screens/splashscreen.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Pass the platform-specific Firebase options
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pet Tracker',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: const Color.fromRGBO(255, 255, 241, 100)),
        useMaterial3: true,
      ),
      // Establishes named routes for the other pages we have.
      getPages: [
        GetPage(name: '/splashscreen', page: () => const SplashScreen()),
        GetPage(name: '/homescreen', page: () => const Home()),
        GetPage(name: '/pet_list', page: () => const PetList()),
        GetPage(name: '/settings', page: () => const Settings())
      ],
      home: const SplashScreen(),
    );
  }
}
