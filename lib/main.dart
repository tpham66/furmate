import 'package:furmate/screens/main_navigation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:firebase_core/firebase_core.dart'; // Import firebase_core package
import 'package:furmate/screens/pet_list.dart';
import 'package:furmate/screens/settings.dart';
import 'firebase_options.dart'; // Import the generated firebase_options.dart file
import 'screens/signin.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart'; // Import foundation for kDebugMode

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    providerWeb: kDebugMode
      ? WebDebugProvider()
      : ReCaptchaEnterpriseProvider('6Lc5yRAuAAAAACGxZ24tGvpU3qpJF9dhETwhEEFA'),
    providerAndroid: kDebugMode ? const AndroidDebugProvider() : const AndroidDebugProvider(),
    providerApple: kDebugMode ? const AppleDebugProvider() : const AppleDebugProvider(),
  );
try {
  await FirebaseAppCheck.instance.getToken(true);
  debugPrint('App Check token request succeeded');
} catch (e) {
  debugPrint('App Check token request failed: $e');
}
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FurMate',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFF2C1),
        ),
        useMaterial3: true,
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
              (states) {
                if (states.contains(WidgetState.hovered)) {
                  return const Color(0xFFFCE8AD);
                }
                return null;
              },
            ),
          ),
        ),
      ),

      // Support dependencies still using flutter/material.dart.
      builder: (context, child) {
        return MaterialUiCompatibilityBridge(
          child: child!,
        );
      },

      routes: {
        '/splashscreen': (context) => const SignIn(),
        '/homescreen': (context) => const MainNavigation(),
        '/pet_list': (context) => const PetList(),
        '/settings': (context) => const Settings(),
        // '/feeding_tracker': (context) => const FeedingTracker(),
      },

      home: const SignIn(),
    );
  }
}

