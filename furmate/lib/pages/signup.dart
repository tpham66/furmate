import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'signin.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUp> {
  // Capture user's email and password
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Strong password format
  bool isStrongPassword(String password) {
  // Minimum 8 characters, at least one uppercase letter, one lowercase letter, one number and one special character
  final RegExp passwordRegex = RegExp(
    r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]{8,}$',
  );
  return passwordRegex.hasMatch(password);
}
  // Function to hangle signup using firebase authentication
  Future<void> handleSignUp() async {
    String email = emailController.text;
    String password = passwordController.text;

    if (!isStrongPassword(password)) {
      showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Weak Password'),
        content: const Text(
            'Password must be at least 8 characters long and include an uppercase letter, a number, and a special character.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return;
    }

    try {
      // create new account using firebase authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Now navigate to login page
      if (kDebugMode) {
        print('Email: ${userCredential.user?.email}');
      }

      if (!mounted) return;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SignIn()));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      // Handle error
      String errorMessage = '';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else {
        errorMessage = 'An unknown error occurred.';
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign Up Failed'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Align(
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              Image.asset('assets/images/furmateLogo.jpg',),
              const Text(
                'Email',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Arial',
                ),
              ),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'email@domain.com',
                  ),
                ),
              ),
              const Text(
                'Password',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Arial',
                ),
              ),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    hintText: '********',
                  ),
                  obscureText: true,
                ),
              ),
              ElevatedButton(onPressed: handleSignUp, child: Text('Signup')),
              Text('OR'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // center the objects in row
                children: [
                  Image.asset('assets/icons/google.png', width: 30, height: 30),
                  SizedBox(width: 20),
                  Image.asset('assets/icons/facebook.png', width: 30, height: 30),
                  SizedBox(width: 20),
                  Image.asset('assets/icons/apple.png', width: 30, height: 30),
                  InkWell(
                    onTap: () {
                      // Action to be performed when the icon is clicked
                      print('Icon clicked');
                    },
                    child: Icon(Icons.home, size: 30), // The icon you want to display
                  )
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignIn()));
                  },
                  child: const Text(
                    'Already have an account? Login',
                    style: TextStyle(
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
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

