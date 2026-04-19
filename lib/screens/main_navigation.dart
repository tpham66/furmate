import 'package:flutter/material.dart';
import 'home.dart';
import 'pet_list.dart';
import 'settings.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentPageIndex = 0;

  final List<Widget> pages = const [
    Home(),
    PetList(),
    Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        height: 86,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, 1), // shifts the light center downward
            radius: 2, // make it stretch horizontally
            colors: [
              Color(0xFFFCE8AD),
              Color(0xFFDDA853),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: Colors.transparent,
            labelTextStyle: WidgetStateProperty.all(
              const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
              if (states.contains(WidgetState.selected)) {
                return IconThemeData(color: Colors.black, size: 28);
              }
              return const IconThemeData(color: Colors.grey, size: 24);
            }),
          ),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            selectedIndex: currentPageIndex,
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.pets_rounded),
                label: 'My Pets',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
      body: pages[currentPageIndex],
    );
  }
}
