
import 'package:furmate/screens/feeding_tracker.dart';
import '../data/pet.dart';
import 'package:material_ui/material_ui.dart';

import '../widgets/general/image.dart';

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
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 150,
          title: Row(
            children: [
              CustomImage(
                id: widget.pet.id,
                imagePath: widget.pet.imagePath,
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
              Tab(text: 'Feeding', icon: Icon(Icons.restaurant)),
              Tab(text: 'Expenses', icon: Icon(Icons.wallet)),
              Tab(text: 'Health', icon: Icon(Icons.health_and_safety)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
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
