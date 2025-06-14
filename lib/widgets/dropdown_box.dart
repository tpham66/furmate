import 'package:flutter/material.dart';
import '../services/activities.dart';

class DropdownBox extends StatelessWidget {
  final Activity tag; // Current selected activity
  final ValueChanged<Activity?>
      onChanged; // Callback when a new item is selected

  const DropdownBox({
    super.key,
    required this.tag,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Activity>(
        value: tag, // Safely handle if tag is null
        onChanged: onChanged,
        items: Activity.values.map((activity) {
          return DropdownMenuItem<Activity>(
            value: activity,
            child: Text(activity.name),
          );
        }).toList(),
        selectedItemBuilder: (BuildContext context) {
          return Activity.values.map((activity) {
            return Row(
              children: [
                const SizedBox(width: 8), // Space between icon and text
                Text(activity.name),
                const SizedBox(width: 10),
              ],
            );
          }).toList();
        });
  }
}
