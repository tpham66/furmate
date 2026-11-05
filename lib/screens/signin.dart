import 'package:furmate/widgets/general/interactive_logo.dart';
import '../services/authentication/google_auth_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'main_navigation.dart';
import '../widgets/general/button.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  SignInState createState() => SignInState();
}

class SignInState extends State<SignIn> {
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  InteractiveLogo(),
                  Title(
                    color: Colors.brown,
                    child: Text(
                      'FurMate',
                      style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Inter'),
                    )
                  ),
      
                  const SizedBox(height: 50),
                  CustomButton(
                    onTap: () async {
                      // Sign in with Google
                      final userCredential =
                          await _googleAuthService.signInWithGoogle();
                      if (!mounted) return;
                      if (userCredential != null) {
                        // Navigate to the next screen
                        Get.offAll(() =>
                            MainNavigation()); // Navigate to PetList screen
                      }
                    },
                    label: 'Sign in with Google',
                    width: 300,
                  ),
                ],
              ),
            ),
          ),
        )
      )
    );
  }
}
