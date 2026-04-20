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
      body: pages[currentPageIndex],
      bottomNavigationBar: Container(
        height: 86,
        decoration: BoxDecoration(
          gradient: const RadialGradient(
            center: Alignment(0.0, 1.0),
            radius: 2,
            colors: [
              Color(0xFFFCE8AD),
              Color(0xFFDDA853),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          child: Padding(padding: const EdgeInsets.only(top: 20),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                indicatorColor: Colors.transparent,
                labelTextStyle: WidgetStateProperty.all(
                  const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                iconTheme:
                    WidgetStateProperty.resolveWith<IconThemeData>((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const IconThemeData(
                      color: Colors.black,
                      size: 28,
                    );
                  }
                  return const IconThemeData(
                    color: Colors.grey,
                    size: 24,
                  );
                }),
              ),
              child: NavigationBar(
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
                selectedIndex: currentPageIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    currentPageIndex = index;
                  });
                },
                destinations: const [
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
        ),
      ),
    );
  }
}