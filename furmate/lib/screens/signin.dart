import 'package:firebase_auth/firebase_auth.dart';
import 'package:furmate/widgets/interactive_logo.dart';
import '../services/google_auth_service.dart';
import '../services/facebook_auth_service.dart';
import 'package:get/get.dart';
import '../widgets/error_dialog.dart';
import 'package:flutter/material.dart';
import 'signup.dart';
import 'main_navigation.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  SignInState createState() => SignInState();
}

class SignInState extends State<SignIn> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final FacebookAuthService _facebookAuthService = FacebookAuthService();

  bool passwordVisible = false;

  Future<void> handleSignIn() async {
    String email = emailController.text;
    String password = passwordController.text;

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        if (!mounted) return;
        Get.offAll(() => MainNavigation());
      } else {
        showDialog(
            context: context,
            builder: (context) => ErrorDialog(
                title: 'Verify Email',
                message: 'Please verify your email to sign in'));
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String errorMessage = '';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      } else {
        errorMessage = e.code;
      }

      showDialog(
        context: context,
        builder: (context) =>
            ErrorDialog(title: 'Sign In failed', message: errorMessage),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Align(
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              InteractiveLogo(),
              TextFormField(
                controller: emailController,
                style: TextStyle(
                  fontSize: 14,
                ),
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'user@example.com',
                  label: Text('Email', style: TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                style: TextStyle(
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: '********',
                  label: const Text('Password', style: TextStyle(fontSize: 14)),
                  suffixIcon: IconButton(
                    icon: Icon(passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(
                        () {
                          passwordVisible = !passwordVisible;
                        },
                      );
                    },
                  ),
                ),
                obscureText: passwordVisible,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                  onPressed: handleSignIn,
                  child: Text('Sign In', style: TextStyle(fontSize: 14))),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 1, // Line thickness
                      color: Colors.grey, // Line color
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "OR", // The text you want in the middle of the divider
                      style: TextStyle(
                          fontSize: 16, color: Colors.grey), // Text style
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // center the objects in row
                children: [
                  GestureDetector(
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
                    child: Image.asset('assets/icons/google.png',
                        width: 30, height: 30),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () async {
                      // Sign in with facebook
                      final userCredential =
                          await _facebookAuthService.signInWithFacebook();
                      if (!mounted) return;
                      if (userCredential != null) {
                        // Navigate to the next screen
                        Get.offAll(() =>
                            MainNavigation()); // Navigate to PetList screen
                      }
                    },
                    child: Image.asset('assets/icons/facebook.png',
                        width: 30, height: 30),
                  ),
                  SizedBox(width: 20),
                  Image.asset('assets/icons/apple.png', width: 30, height: 30),
                ],
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  Get.to(() => SignUp());
                },
                child: const Text(
                  'Don\'t have an account? Sign Up',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
