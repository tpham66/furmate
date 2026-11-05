import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double width;
  final double height;
  final Gradient gradient;
  final Color borderColor;

  const CustomButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.width,
    this.height = 57,
    this.gradient = const RadialGradient(
      radius: 1,
      colors: [Color(0xFFFCE8AD), Color(0xFFDDA853)],
    ),
    this.borderColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: InkRipple.splashFactory,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: onTap,
          child: Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              gradient: gradient,
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 4, color: borderColor),
                borderRadius: BorderRadius.circular(100),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      )
    );
  }
}
