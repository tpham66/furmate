import 'package:flutter/material.dart';

class InteractiveLogo extends StatefulWidget {
  @override
  InteractiveLogoState createState() => InteractiveLogoState();
}

class InteractiveLogoState extends State<InteractiveLogo>
    with SingleTickerProviderStateMixin {
  bool isLogoInteracted = false;
  late AnimationController _animationController;
  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggle() {
    _animationController.forward(from: 0.0);
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: toggle,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * _animationController.value),
                    child: child,
                  );
                },
                child: Image.asset('assets/images/cat.png')),
            Image.asset('assets/images/dog.png'),
          ],
        ));
  }
}
