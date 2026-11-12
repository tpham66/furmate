import 'package:flutter/material.dart';
import 'package:furmate/services/events/calendar_services.dart';
import '../widgets/home/event_page_indicator.dart';
import '../widgets/home/event_sheet.dart';
import '../data/event.dart';
import '../data/pet.dart';
import '../widgets/home/event_page_view.dart';
import '../widgets/home/custom_date.dart';
import '../widgets/home/custom_divider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/general/error_dialog.dart';
import 'dart:async';
import '../services/settings/enable_notifications.dart';
import '../screens/pet_insights.dart';
import '../widgets/home/calendar.dart';
import '../widgets/home/event_card.dart';

enum Menu { edit, remove, addToCalendar }

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _petsSubscription;
  final PageController _pageController = PageController(viewportFraction: 0.8);
  List<Pet> pets = [];
  List<Event> events = [];
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    listenToPets();
    loadEvents();
  }

  Future<bool> notificationsEnabled() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return doc.data()?['notificationsEnabled'] == true;
  }

  void listenToPets() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _petsSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;

      setState(() {
        pets = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Pet.fromMap(data);
        }).toList();
      });
    }, onError: (error) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => const ErrorDialog(
          title: 'Error',
          message: 'Failed to load pets',
        ),
      );
    });
  }
  
  Future<void> loadEvents() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('events')
          .orderBy('time')
          .get();

      setState(() {
        events = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Event.fromMap(data);
        }).toList();
      });
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => const ErrorDialog(
          title: 'Error',
          message: 'Failed to load event',
        ),
      );
    }
  }

  List<Event> get upcomingEvents {
    final now = DateTime.now();

    return events
        .where((event) => event.time.isAfter(now))
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  List<Event> get pastEvents {
    final now = DateTime.now();

    return events
        .where((event) => !event.time.isAfter(now))
        .toList()
      ..sort((a, b) => b.time.compareTo(a.time));
  }

  String getPetName(Event event) {
    for (final pet in pets) {
      if (pet.id == event.petId) {
        return pet.name;
      }
    }

    return event.petName;
  }

  void _handleMenuSelection(EventCardAction item, Event event) async {
    switch (item) {
      case EventCardAction.edit:
        showModalBottomSheet(
          context: context,
          builder: (ctx) => EventSheet(
            availablePets: pets,
            eventData: event,
            onSave: (updatedEvent) async {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) return;

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('events')
                  .doc(updatedEvent.id)
                  .update(updatedEvent.toMap());

              setState(() {
                final index = events.indexOf(event);
                events[index] = updatedEvent;
                events.sort((a, b) => a.time.compareTo(b.time));
              });

              await NotificationService.instance.cancelEvent(updatedEvent.id);

              if (await notificationsEnabled()) {
                await NotificationService.instance.scheduleEvent(updatedEvent);
              }
            },
          ),
        );
        break;

      case EventCardAction.remove:
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        final eventId = event.id;

        if (!mounted) return;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('events')
            .doc(eventId)
            .delete();

        setState(() {
          events.remove(event);
        });

        await NotificationService.instance.cancelEvent(eventId);
        break;

      case EventCardAction.addToCalendar:
        try {
          await CalendarService.addToGoogleCalendar(event);
        } catch (e) {
          debugPrint("Error to add to calendar: $e");
        }
        break;
    }
  }

  void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => EventSheet(
        availablePets: pets,
        onSave: (newEvent) async {
          try {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) return;

            final docRef = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('events')
                .add(newEvent.toMap());
            final savedEvent = newEvent.copyWith(id: docRef.id);
            if (await notificationsEnabled()) {
              try {
                await NotificationService.instance.scheduleEvent(savedEvent);
              } catch (e) {
                debugPrint('Failed to schedule reminder: $e');
              }
            }
            setState(() {
              events.add(savedEvent);
              events.sort((a, b) => a.time.compareTo(b.time));
            });
          } catch (e) {
            if (!mounted) return;
            showDialog(
              context: context,
              builder: (context) => const ErrorDialog(
                title: 'Error',
                message: 'Failed to save event',
              ),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _petsSubscription?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:
          IconButton(
            onPressed: () async{
              try {
                debugPrint('Starting Gemini request...');

                if (!context.mounted) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AiInsightsPage(),
                  ),
                );
              } catch (e) {
                debugPrint('AI BUTTON ERROR: $e');
              }
          }, 
          icon: const Icon(Icons.insights),
        ),
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.event_note),
            onPressed: () async{
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PetCalendar(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CurrentDateHeading(date: now),
            // PageView with scaling effect
            EventPageView(
              controller: _pageController,
              events: upcomingEvents,
              pets: pets,
            ),

            // Smooth Page Indicator
            EventPageIndicator(
              pageController: _pageController,
              count: upcomingEvents.isEmpty ? 1 : upcomingEvents.length,
            ),

            CustomDivider(),

            const SizedBox(height: 20),

            // Event List
            if (events.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No events added yet.'),
                ),
              )
            else
              ListView.builder(
                padding: const EdgeInsets.all(20),
                physics:
                    const NeverScrollableScrollPhysics(), // Disable inner scrolling
                shrinkWrap: true, // Let the ListView fit its children
                itemCount: upcomingEvents.length + pastEvents.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const ListTile(
                      title: Text(
                        'Upcoming Events',
                        style: TextStyle(fontSize: 20),
                      ),
                    );
                  }

                  if (index <= upcomingEvents.length) {
                    final event = upcomingEvents[index - 1];
                    return EventCard(
                      event: event,
                      petName: getPetName(event),
                      onSelected: (action) => _handleMenuSelection(action, event),
                    );
                  }
                  
                  if (index == upcomingEvents.length + 1) {
                    return const Column(
                      children: [
                        SizedBox(height: 20),
                        Divider(),
                        ListTile(
                          title: Text(
                            'Past Events',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    );
                  }

                  final id = index - upcomingEvents.length - 2;
                  final event = pastEvents[id];
                  return EventCard(
                    event: event,
                    petName: getPetName(event),
                    isPast: true,
                    onSelected: (action) => _handleMenuSelection(action, event),
                  );
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: showBottomSheet, 
          child: const Icon(Icons.add)),
    );
  }
}
