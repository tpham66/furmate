import 'package:flutter/material.dart';
import '../general/dropdown_box.dart';
import '../../services/events/activities.dart';

class EventSheet extends StatefulWidget {
  final List<String> availablePets;
  final Function(Map<String, String>) onSave;

  const EventSheet({
    super.key,
    required this.availablePets,
    required this.onSave,
  });

  @override
  EventSheetState createState() => EventSheetState();
}

class EventSheetState extends State<EventSheet> {
  Activity selectedTag = Activity.pooping;
  final TextEditingController _otherActivity = TextEditingController();
  String? selectedPet;
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              ),
              const Text('Add Event', style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  final activity = _otherActivity.text.isNotEmpty
                      ? _otherActivity.text
                      : selectedTag.name;

                  if (activity.isEmpty || selectedPet == null || selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please complete all fields')),
                    );
                    return;
                  }

                  widget.onSave({
                    'type': activity,
                    'pet': selectedPet!,
                    'time': selectedDate!.toIso8601String(),
                  });

                  Navigator.pop(context);
                },
                child: const Text('Add', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                alignment: Alignment.center,
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 229, 234, 239),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownBox(
                  tag: selectedTag,
                  onChanged: (Activity? value) {
                    setState(() {
                      selectedTag = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _otherActivity,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    labelText: 'Or write your own',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: selectedPet,
            items: widget.availablePets
                .map((pet) => DropdownMenuItem(value: pet, child: Text(pet)))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedPet = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Select Pet',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(selectedDate == null
                ? 'Select time'
                : '${selectedDate!.toLocal()}'.split('.')[0]),
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  setState(() {
                    selectedDate = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                  });
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
