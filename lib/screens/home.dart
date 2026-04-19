import 'package:flutter/material.dart';
import '../widgets/home/event_page_indicator.dart';
import 'package:intl/intl.dart';
import '../widgets/home/event_sheet.dart';
import '../models/event.dart';

import '../widgets/home/event_page_view.dart';
import '../widgets/home/custom_date.dart';
import '../widgets/home/custom_divider.dart';

enum Menu { edit, remove }

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  List<Map<String, String>> availablePets = [];
  List<Event> events = [];
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();

  }


  

  void _handleMenuSelection(Menu item, int index) async {
    switch (item) {
      case Menu.edit:
        
        break;

      case Menu.remove:
       
        break;
    }
  }

  void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => EventSheet(
        availablePets:
            availablePets.map((pet) => pet['name'] ?? 'Unnamed').toList(),
        onSave: (newEvent) async {
          print(newEvent);


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
              itemCount: events.isEmpty ? 1 : events.length,
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
          onPressed: showBottomSheet, child: const Icon(Icons.add)),
    );
  }
}
