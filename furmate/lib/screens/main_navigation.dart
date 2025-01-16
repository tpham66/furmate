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
      bottomNavigationBar: NavigationBarTheme(
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
              return const IconThemeData(color: Colors.indigo, size: 28);
            }
            return const IconThemeData(color: Colors.grey, size: 24);
          }),
        ),
        child: NavigationBar(
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
      body: pages[currentPageIndex],
    );
  }
}
