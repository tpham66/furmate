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
              color: Colors.blue,
            ),
          ),
        ],
      ),
      style: const TextStyle(fontSize: 20),
    );
  }
}
