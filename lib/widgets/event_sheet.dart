import 'package:flutter/material.dart';
import '../widgets/dropdown_box.dart';
import '../services/activities.dart';

class EventSheet extends StatefulWidget {
  final Map<String, String>? events; // Null for adding a new event
  final Function(Map<String, String>) onSave; // Callback for saving the event
  EventSheet({super.key, this.events, required this.onSave});

  @override
  EventSheetState createState() => EventSheetState();
}

class EventSheetState extends State<EventSheet> {
  Activity selectedTag = Activity.pooping;
  final TextEditingController _otherActivity = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        )),
                    Text('More Event'),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Add',
                          style: TextStyle(color: Colors.blue),
                        ))
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
                        borderRadius:
                            BorderRadius.circular(20), // Rounded corners
                      ),
                      child: DropdownBox(
                        tag: selectedTag,
                        onChanged: (Activity? value) {
                          setState(() {
                            selectedTag = value!;
                          });
                        },
                      )
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _otherActivity,
                        
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          labelText: 'If other *',
                        ),
                      )
                    )
                  ]
                ),
              ],
            )));
  }
}
