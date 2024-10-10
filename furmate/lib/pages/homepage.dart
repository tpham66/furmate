import 'package:flutter/material.dart';
import 'signup.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FurMate Home'),
      ),
      body: Center(
        child: Column (
          children: [
            Image.asset('assets/images/furmateLogo.jpg'),
            Title(color: Colors.brown, child: Text('FurMate')),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUp()),
                );
              },
              child: Text('Next'),
            ),
          ]
        )
      ),
    );
  }
}
