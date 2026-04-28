import 'package:flutter/material.dart';
import 'package:furmate/widgets/general/error_dialog.dart';
import '../general/dropdown_box.dart';
import '../../services/events/activities.dart';
import '../../data/event.dart';
import 'package:uuid/uuid.dart';


class EventSheet extends StatefulWidget {
  final List<String> availablePets;
  final Function(Event) onSave;
  final Event? eventData;

  const EventSheet({
    super.key,
    required this.availablePets,
    required this.onSave,
    this.eventData,
  });

  @override
  EventSheetState createState() => EventSheetState();
}

class EventSheetState extends State<EventSheet> {
  Activity selectedTag = Activity.pooping;
  final TextEditingController _otherActivity = TextEditingController();
  final TextEditingController _person = TextEditingController();
  String? selectedPet;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();

    if (widget.eventData != null) {
      selectedPet = widget.eventData!.pet;
      selectedDate = widget.eventData!.time;
      _person.text = widget.eventData!.person;
      _otherActivity.text = widget.eventData!.type;
    }
  }

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
              Text(widget.eventData == null ? 'Add Event' : 'Edit Event', style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  final activity = _otherActivity.text.isNotEmpty
                      ? _otherActivity.text
                      : selectedTag.name;

                  if (activity.isEmpty || selectedPet == null || selectedDate == null || _person.text.trim().isEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) => const ErrorDialog(
                        title: 'Error',
                        message: 'Please complete all fields',
                      ),
                    );
                    return;
                  }

                  widget.onSave(Event(
                    id: widget.eventData?.id ?? const Uuid().v4(),
                    type: activity,
                    pet: selectedPet!,
                    person: _person.text,
                    time: selectedDate!,
                  ));

                  Navigator.pop(context);
                },
                child: Text(widget.eventData == null ? 'Add' : 'Save', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                alignment: Alignment.topLeft,
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade600),
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
            decoration: InputDecoration(
              labelText: 'Select Pet',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade600),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(selectedDate == null
                  ? 'Select time'
                  : '${selectedDate!.toLocal()}'.split('.')[0]),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (!mounted || pickedDate == null) return;

                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (!mounted || pickedTime == null) return;

                setState(() {
                  selectedDate = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: _person,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                labelText: 'Person',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
