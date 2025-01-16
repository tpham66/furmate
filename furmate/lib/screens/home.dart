import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../widgets/event_sheet.dart';
import '../services/activities.dart';

List<Map<String, String>> events = [
  {'Pooping': 'Phu'},
  {'Feeding': 'Ha'},
  {'Walking': 'Duong'},
  {'Playing': 'Binh'},
  {'Visiting vet': 'Son'}
]; // This is just for hardcode

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  final PageController _pageController = PageController(viewportFraction: 0.8);

  DateTime now = DateTime.now();

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
            onPressed: () {
              // Add task
              print(FirebaseAuth.instance.currentUser?.email ?? 'No user');
              print(events);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text.rich(
              TextSpan(
                text: DateFormat('EEE ').format(now),
                style: TextStyle(fontSize: 30),
                children: <TextSpan>[
                  TextSpan(
                    text: DateFormat('MMM d').format(now),
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.blue),
                  ),
                ],
              ),
              style:
                  TextStyle(fontSize: 20), // Default style for the entire text
            ),

            // PageView with scaling effect
            SizedBox(
              height: 300, // Fixed height for the PageView
              child: PageView.builder(
                controller: _pageController,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_pageController.position.haveDimensions) {
                        value = _pageController.page! - index;
                        value = (1 - (value.abs() * 0.2)).clamp(0.8, 1.0);
                      }

                      return Center(
                        child: SizedBox(
                          height: Curves.easeOut.transform(value) * 300,
                          width: Curves.easeOut.transform(value) * 3300,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color:
                            Colors.primaries[index % Colors.primaries.length],
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Page ${index + 1}',
                          style: const TextStyle(
                              fontSize: 24, color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Smooth Page Indicator
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 5, // Match the PageView's itemCount
                effect: WormEffect(
                  activeDotColor: Colors.blue,
                  dotColor: Colors.grey,
                  dotHeight: 12,
                  dotWidth: 12,
                ),
              ),
            ),

            Stack(
              children: [
                // Main divider
                Container(
                  height: 15, // Divider thickness
                  color: Colors.grey, // Main divider color
                ),
                // Top-to-bottom shadow
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      backgroundBlendMode: BlendMode.screen,
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey, // Middle shadow
                          Colors.black
                              .withOpacity(0.3), // Transparent in the middle
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ],
            ),

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
                      title: Text(events[index].keys.first),
                      subtitle: Text(events[index].values.first),
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

  void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => EventSheet(
        events: null, // Indicate this is a new pet
        onSave: (newEvent) {
          setState(() {
            events.add(newEvent); // Add the new pet to the list
          });
        },
      ),
    );
  }
}
