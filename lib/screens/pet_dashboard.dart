
import 'package:furmate/screens/feeding_tracker.dart';
import '../data/pet.dart';
import 'package:material_ui/material_ui.dart';

class PetDashboard extends StatefulWidget {
  final Pet pet;

  const PetDashboard({
    super.key,
    required this.pet,
  });

  @override
  PetDashboardState createState() => PetDashboardState();
}

class PetDashboardState extends State<PetDashboard> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.pet.name),
          
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Feeding'),
              Tab(text: 'Expenses'),
              Tab(text: 'Health'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Overview
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('Name: ${widget.pet.name}'),
                  Text('Species: ${widget.pet.species}'),
                  Text('Breed: ${widget.pet.breed}'),
                  Text(
                    'Weight: ${widget.pet.weight} '
                    '${widget.pet.weightUnit}',
                  ),
                ],
              ),
            ),

            // Feeding
            FeedingTracker(pet: widget.pet),

            // Expenses
            const Center(
              child: Text('Pet Expenses'),
            ),

            // Health
            const Center(
              child: Text('Health Records'),
            ),
          ],
        ),
      ),
    );
  }
}
