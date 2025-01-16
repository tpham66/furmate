import 'package:flutter/material.dart';
import 'signup.dart';
import 'signin.dart';
import '../widgets/interactive_logo.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InteractiveLogo(),
            Title(
                color: Colors.brown,
                child: Text(
                  'FurMate',
                  style: TextStyle(
                      fontSize: 70,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Inter'),
                )),
            const SizedBox(height: 70),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignIn()),
                    );
                  },
                  child: Text('Sign In'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUp()),
                    );
                  },
                  child: Text('Sign Up')
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
