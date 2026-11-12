
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/event.dart';

enum EventCardAction { edit, remove, addToCalendar }

class EventCard extends StatelessWidget {
  final Event event;
  final String petName;
  final bool isPast;
  final void Function(EventCardAction action) onSelected;

  const EventCard({
    super.key,
    required this.event,
    required this.petName,
    required this.onSelected,
    this.isPast = false,
  });

  String get formattedDate {
    final date = event.time;

    if (!isPast) {
      final now = DateTime.now();
      final tomorrow = DateTime(
        now.year,
        now.month,
        now.day + 1,
      );

      if (DateUtils.isSameDay(date, now)) {
        return 'Today';
      }

      if (DateUtils.isSameDay(date, tomorrow)) {
        return 'Tomorrow';
      }
    }

    return DateFormat('MMM d').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),
      color: isPast ? Colors.grey.shade300 : null,
      child: ListTile(
        leading: const Icon(Icons.pets),
        title: Text(
          '${event.type} • $petName',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '$formattedDate • '
          '${DateFormat('hh:mm a').format(event.time)}',
        ),
        trailing: MenuAnchor(
          animated: true,
          builder: (context, controller, child) {
            return IconButton(
              icon: const Icon(Icons.more_vert),
              tooltip: 'Options',
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
            );
          },
          menuChildren: [
            MenuItemButton(
              onPressed: () =>
                  onSelected(EventCardAction.edit),
              leadingIcon: const Icon(Icons.edit),
              child: const Text('Edit'),
            ),
            MenuItemButton(
              onPressed: () =>
                  onSelected(EventCardAction.remove),
              leadingIcon: const Icon(Icons.delete),
              child: const Text('Remove'),
            ),
            MenuItemButton(
              onPressed: () =>
              onSelected(EventCardAction.addToCalendar),
              leadingIcon: const Icon(Icons.calendar_month),
              child: const Text('Add to Google Calendar'),
            )
          ],
        ),
      ),
    );
  }
}
