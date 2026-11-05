import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrentDateHeading extends StatelessWidget {
  final DateTime date;

  const CurrentDateHeading({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: DateFormat('EEE ').format(date),
        style: const TextStyle(fontSize: 30),
        children: <TextSpan>[
          TextSpan(
            text: DateFormat('MMM d').format(date),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color.fromARGB(255, 71, 47, 3),
            ),
          ),
        ],
      ),
      style: const TextStyle(fontSize: 20),
    );
  }
}
