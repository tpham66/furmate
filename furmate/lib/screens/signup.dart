import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:furmate/screens/home.dart';
import '../services/google_auth_service.dart';
import '../services/facebook_auth_service.dart';
import 'package:get/get.dart';
import 'signin.dart';
import '../widgets/error_dialog.dart';
import '../widgets/interactive_logo.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUp> {
  // Capture user's email and password
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Handle sign in with google, facebook, and apple
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final FacebookAuthService _facebookAuthService = FacebookAuthService();

  bool passwordVisible = false;

  // Strong password format
  bool isStrongPassword(String password) {
    // Minimum 8 characters, at least one uppercase letter, three lowercase letter, one number and one special character
    final RegExp passwordRegex = RegExp(
      r'^(?=(.*[A-Z]){1,})(?=(.*[a-z]){3,})(?=(.*\d){2,})(?=(.*[@$!%*?&#]){1,})[A-Za-z\d@$!%*?&#]{8,}$',
    );

    return passwordRegex.hasMatch(password);
  }

  // Function to hangle signup using firebase authentication
  Future<void> handleSignUp() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      if (!isStrongPassword(password)) {
        throw Exception(
            'Password must be at least 8 characters long and include an uppercase letter, a number, and a special character.');
      }
      // create new account using firebase authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      await FirebaseAuth.instance.setLanguageCode("fr");
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      Get.to(() => SignIn());
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      // Handle error
      String errorMessage = '';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      } else {
        errorMessage = 'An unknown error occurred.';
      }

      showDialog(
        context: context,
        builder: (context) =>
            ErrorDialog(title: 'Sign Up Failed', message: errorMessage),
      );
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) =>
            ErrorDialog(title: 'Weak password', message: e.toString()),
      );
    }
  }

  Future<void> signInWithApple() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Align(
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              InteractiveLogo(),
              TextFormField(
                controller: _emailController,
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
                style: TextStyle(
                  fontSize: 14,
                ),
                controller: _passwordController,
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
                  onPressed: handleSignUp,
                  child: Text('Sign Up', style: TextStyle(fontSize: 14))),
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
                        Get.offAll(() => Home());
                      }
                    },
                    child: Image.asset('assets/icons/google.png',
                        width: 30, height: 30),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () async {
                      // Sign in with facebook
                      final userCredential =
                          await _facebookAuthService.signInWithFacebook();
                      if (!mounted) return;
                      if (userCredential != null) {
                        // Navigate to the next screen
                        Get.offAll(() => Home());
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
                  Get.to(() => SignIn());
                },
                child: const Text(
                  'Already have an account? Sign In',
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
