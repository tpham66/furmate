import 'package:flutter/material.dart';
import '../widgets/home/event_page_indicator.dart';
import 'package:intl/intl.dart';
import '../widgets/home/event_sheet.dart';
import '../models/event.dart';
import '../models/pet.dart';
import '../widgets/home/event_page_view.dart';
import '../widgets/home/custom_date.dart';
import '../widgets/home/custom_divider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/general/error_dialog.dart';

enum Menu { edit, remove }

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  List<Pet> pets = [];
  List<Event> events = [];
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadPets();
    loadEvents();
  }

  Future<void> loadPets() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .get();

      setState(() {
        pets = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Pet.fromMap(data);
        }).toList();
      });
    } catch (e) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => const ErrorDialog(
          title: 'Error',
          message: 'Failed to load pets',
        ),
      );
    }
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
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => const ErrorDialog(
          title: 'Error',
          message: 'Failed to load event',
        ),
      );
    }
  }

  void _handleMenuSelection(Menu item, int index) async {
    switch (item) {
      case Menu.edit:
        showModalBottomSheet(
          context: context,
          builder: (ctx) => EventSheet(
            availablePets: pets.map((pet) => pet.name).toList(),
            eventData: events[index],
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
                events[index] = updatedEvent;
                events.sort((a, b) => a.time.compareTo(b.time));
              });
            },
          ),
        );
        break;

      case Menu.remove:
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        final eventId = events[index].id;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('events')
            .doc(eventId)
            .delete();

        setState(() {
          events.removeAt(index);
        });
        break;
    }
  }

  void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => EventSheet(
        availablePets:
            pets.map((pet) => pet.name).toList(),
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
            setState(() {
              events.add(savedEvent);
              events.sort((a, b) => a.time.compareTo(b.time));
            });
          } catch (e) {
            if (!context.mounted) return;
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
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:
            IconButton(onPressed: () {}, icon: const Icon(Icons.ssid_chart)),
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.event_note),
            onPressed: () {},
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
              events: events,
            ),

            // Smooth Page Indicator
            EventPageIndicator(
              pageController: _pageController,
              count: events.isEmpty ? 1 : events.length,
            ),

            CustomDivider(),

            const SizedBox(height: 20),

            const Text(
              'Events',
              style: TextStyle(fontSize: 30),
            ),

            // Event List
            if (events.isEmpty)
              const Center(
                child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No events added yet.'),
              ))
            else
              ListView.builder(
                physics:
                    const NeverScrollableScrollPhysics(), // Disable inner scrolling
                shrinkWrap: true, // Let the ListView fit its children
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.pets),
                      title: Text(events[index].type),
                      subtitle: Text(
                          '${events[index].pet} • ${DateFormat('hh:mm a').format(events[index].time)}'),
                      trailing: PopupMenuButton<Menu>(
                        icon: Icon(Icons.more_vert),
                        onSelected: (item) => _handleMenuSelection(item, index),
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: Menu.remove,
                            child: ListTile(
                              leading: Icon(Icons.delete),
                              title: Text('Remove'),
                            ),
                          ),
                        ],
                      ),
                    ),
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
