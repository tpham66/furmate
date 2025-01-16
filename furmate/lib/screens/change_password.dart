import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});
  @override
  ChangePasswordState createState() => ChangePasswordState();
}

class ChangePasswordState extends State<ChangePassword> {
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _currPasswordController = TextEditingController();

  ///Passing a key to access the validate function
  final GlobalKey<FlutterPwValidatorState> validatorKey =
      GlobalKey<FlutterPwValidatorState>();
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Key for the form

  bool currPasswordVisible = false;
  bool passwordVisible1 = false;
  bool passwordVisible2 = false;

  Future<void> reauthenticateAndChangePassword() async {
    try {
      // Get the current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
            code: 'no-current-user', message: 'No user currently signed in.');
      }

      // Get the user's current email
      final email = user.email;
      if (email == null) {
        throw FirebaseAuthException(
            code: 'no-email',
            message: 'No email associated with this account.');
      }

      // Prompt for the current password to reauthenticate
      final currentPassword = _currPasswordController.text.trim();

      // Create credential using the email and current password
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      // Reauthenticate the user
      await user.reauthenticateWithCredential(credential);

      // If successful, update the password
      await user.updatePassword(_passwordController.text.trim());
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully.')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: new TextFormField(
                  obscureText: currPasswordVisible,
                  controller: _currPasswordController,
                  decoration: new InputDecoration(
                    labelText: 'Current password *',
                    hintText: '********',
                    suffixIcon: IconButton(
                      icon: Icon(currPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(
                          () {
                            currPasswordVisible = !currPasswordVisible;
                          },
                        );
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: new TextFormField(
                    obscureText: passwordVisible1,
                    controller: _passwordController,
                    decoration: new InputDecoration(
                      labelText: 'New password *',
                      hintText: '********',
                      suffixIcon: IconButton(
                        icon: Icon(passwordVisible1
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(
                            () {
                              passwordVisible1 = !passwordVisible1;
                            },
                          );
                        },
                      ),
                    )),
              ),
              FlutterPwValidator(
                key: validatorKey,
                controller: _passwordController,
                minLength: 8,
                uppercaseCharCount: 1,
                lowercaseCharCount: 3,
                numericCharCount: 2,
                specialCharCount: 1,
                normalCharCount: 3,
                width: 300,
                height: 200,
                onSuccess: () {
                  print("MATCHED");
                  ScaffoldMessenger.of(context).showSnackBar(
                      new SnackBar(content: new Text("Password is matched")));
                },
                onFail: () {
                  print("NOT MATCHED");
                },
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: new TextFormField(
                  obscureText: passwordVisible2,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm password *',
                    hintText: '********',
                    suffixIcon: IconButton(
                      icon: Icon(passwordVisible2
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(
                          () {
                            passwordVisible2 = !passwordVisible2;
                          },
                        );
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Password confirmation doesn\'t match';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(50),
                  child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await reauthenticateAndChangePassword();
                        }
                      },
                      child: const Text('Change password')))
            ],
          ),
        ),
      ),
    );
  }
}
