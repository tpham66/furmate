import 'package:flutter/material.dart';
import 'signup.dart';
import 'signin.dart';
import '../widgets/interactive_logo.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
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
            Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => SignIn());
                  },
                  child: Text(
                    'Sign In',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height:10),
                ElevatedButton(
                    onPressed: () {
                      Get.to(() => SignUp());
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 14),
                    ))
              ],
            ),
            const SizedBox(height: 150,),
          ],
        ),
      ),
    );
  }
}
