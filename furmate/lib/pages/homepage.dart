import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: Text('FurMate Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // addPetData('Buddy', 'Dog', 5);
          },
          child: Text('Add Pet'),
        ),
      ),
    );
  }
}