import 'package:flutter/material.dart';
import '../../services/events/activities.dart';

class DropdownBox extends StatelessWidget {
  final Activity tag;
  final ValueChanged<Activity?> onChanged;

  const DropdownBox({
    super.key,
    required this.tag,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120, // adjust as needed
      child: MenuAnchor(
        alignmentOffset: const Offset(0, 4),
        style: MenuStyle(
          alignment: AlignmentDirectional.bottomStart,
          backgroundColor: const WidgetStatePropertyAll(Colors.white),
          elevation: const WidgetStatePropertyAll(8),
          minimumSize: const WidgetStatePropertyAll(Size(120, 0)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(vertical: 8),
          ),
        ),
        menuChildren: Activity.values.map((activity) {
          final isSelected = activity == tag;

          return MenuItemButton(
            onPressed: () => onChanged(activity),
            trailingIcon: isSelected ? const Icon(Icons.check, size: 18) : null,
            child: Text(activity.name),
          );
        }).toList(),
        builder: (context, controller, child) {
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tag.name),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}