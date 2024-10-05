import 'package:flutter/material.dart';

class SignUp extends StatelessWidget {
  // Use super parameters for the key
  const SignUp({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signup'),
      ),
      body: Align(
        alignment: Alignment.centerLeft
        child: Row (
          children: <Widget> [
            const Text(
              'Name',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Arial',
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
          ]
        )
      ),
    );
  }
}
