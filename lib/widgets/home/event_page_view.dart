import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/event.dart';
import 'dart:math';

final random = Random();

const pastelPalette = [
  Color(0xFFEFC7B0),
  Color(0xFFF7D8BA),
  Color(0xFFF2E3C6),
  Color(0xFFD9E8C8),
  Color(0xFFCFE5D6),
  Color(0xFFD7E6E9),
  Color(0xFFDCCFF1),
  Color(0xFFEBCFE3),
];

class EventPageView extends StatelessWidget {
  final PageController controller;
  final List<Event> events;

  const EventPageView({
    super.key,
    required this.controller,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    final displayCount = events.isEmpty ? 1 : events.length;

    return SizedBox(
      height: 330,
      child: PageView.builder(
        controller: controller,
        itemCount: displayCount,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              double value = 1.0;
              if (controller.hasClients && controller.position.haveDimensions) {
                value = controller.page! - index;
                value = (1 - (value.abs() * 0.2)).clamp(0.8, 1.0);
              }

              return Center(
                child: SizedBox(
                  height: Curves.easeOut.transform(value) * 300,
                  width: Curves.easeOut.transform(value) * 330,
                  child: child,
                ),
              );
            },
            child: events.isEmpty
                ? Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'No events yet',
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                  )
                : _EventCard(event: events[index], index: index),
          );
        },
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  final int index;

  const _EventCard({
    required this.event,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: pastelPalette[index % pastelPalette.length],
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('MMM d, yyyy').format(event.time),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 58, 58, 58),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('hh:mm a').format(event.time),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 58, 58, 58),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${event.pet}: ${event.type}',
            style: const TextStyle(fontSize: 18, color: Color.fromARGB(255, 58, 58, 58)),
          ),
          const SizedBox(height: 8),
          Text(
            'Person: ${event.person}',
            style: const TextStyle(fontSize: 18, color: Color.fromARGB(255, 58, 58, 58)),
          ),
        ],
      ),
    );
  }
}