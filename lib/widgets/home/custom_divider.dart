import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main divider
        Container(
          height: 15,
          color: Colors.grey,
        ),
        // Top-to-bottom shadow
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              backgroundBlendMode: BlendMode.screen,
              gradient: LinearGradient(
                colors: [
                  Colors.grey,
                  Colors.black.withOpacity(0.3),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
