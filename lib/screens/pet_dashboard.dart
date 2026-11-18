
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
    final imageUrl = widget.pet.imagePath.trim();
    final hasImage = Uri.tryParse(imageUrl)?.hasAbsolutePath == true &&
    imageUrl.startsWith('https://');
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 150,
          title: Row(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: hasImage
                        ? NetworkImage(imageUrl)
                        : null,
                child: !hasImage
                    ? const Icon(
                        Icons.pets,
                        size: 40,
                        color: Colors.grey,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.pet.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${widget.pet.breed} · ${widget.pet.age} years old',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ]
          ),
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
