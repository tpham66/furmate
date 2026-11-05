
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../data/event.dart';

class PetCalendar extends StatefulWidget {
  const PetCalendar({super.key});

  @override
  State<PetCalendar> createState() => _PetCalendarState();
}

class _PetCalendarState extends State<PetCalendar> {
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  List<Event> events = [];

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('events')
          .get();

      final loadedEvents = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Event.fromMap(data);
      }).toList();

      if (!mounted) return;

      setState(() {
        events = loadedEvents;
      });
    } catch (e) {
      debugPrint('Calendar loading error: $e');
    }
  }

  List<Event> getEventsForDay(DateTime day) {
    return events.where((event) {
      return isSameDay(event.time, day);
    }).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }


Future<void> showMonthYearPicker() async {
  int year = focusedDay.year;
  bool selectingMonth = false;

  final chosenDate = await showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, updateSheet) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectingMonth ? 'Select Month · $year' : 'Select Year',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: selectingMonth ? 12 : 16,
                    itemBuilder: (context, index) {
                      final value = selectingMonth
                          ? index + 1
                          : 2020 + index;

                      final label = selectingMonth
                          ? DateFormat.MMM().format(
                              DateTime(year, value),
                            )
                          : '$value';

                      return OutlinedButton(
                        onPressed: () {
                          if (!selectingMonth) {
                            updateSheet(() {
                              year = value;
                              selectingMonth = true;
                            });
                          } else {
                            Navigator.pop(
                              sheetContext,
                              DateTime(year, value, 1),
                            );
                          }
                        },
                        child: Text(label),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  if (!mounted || chosenDate == null) return;

  setState(() {
    focusedDay = chosenDate;
    selectedDay = chosenDate;
  });
}


  @override
  Widget build(BuildContext context) {
    final selectedEvents = getEventsForDay(selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar<Event>(
            key: ValueKey('${focusedDay.year}-${focusedDay.month}'),
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: focusedDay,

            onHeaderTapped: (day) => showMonthYearPicker(),

            selectedDayPredicate: (day) {
              return isSameDay(selectedDay, day);
            },
            onDaySelected: (selected, focused) {
              setState(() {
                selectedDay = selected;
                focusedDay = focused;
              });
            },

            eventLoader: getEventsForDay,

            onPageChanged: (focused) {
              focusedDay = focused;
            },

            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Color(0xFFD9C8B8),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Color(0xFF9F795E),
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Color(0xFF9F795E),
                shape: BoxShape.circle,
              ),
            ),

            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                DateFormat('MMMM d, yyyy').format(selectedDay),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: selectedEvents.isEmpty
                ? const Center(
                    child: Text('No events for this day'),
                  )
                : ListView.builder(
                    itemCount: selectedEvents.length,
                    itemBuilder: (context, index) {
                      final event = selectedEvents[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.pets),
                          title: Text(event.type),
                          subtitle: Text(event.petName),
                          trailing: Text(
                            DateFormat('hh:mm a')
                                .format(event.time),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
