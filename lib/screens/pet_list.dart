import 'package:flutter/material.dart';
import 'package:furmate/screens/pet_profile.dart';
import 'package:get/get.dart';

enum Menu { edit, remove }

List<Map<String, String>> pets = [];

class PetList extends StatefulWidget {
  const PetList({super.key});

  @override
  PetListState createState() => PetListState();
}

class PetListState extends State<PetList> {

  void _handleMenuSelection(Menu item, int index) {
    switch (item) {
      case Menu.edit:
        // Handle edit action
        Get.to(
          () => PetProfile(
            petData: pets[index],
            onSave: (updatedPet) {
              setState(() {
                pets[index] = updatedPet;
              });
            },
          ),
        );
        break;
      case Menu.remove:
        // Handle remove action
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${pets[index]['name']} removed')),
        );
        setState(() {
          pets.removeAt(index);
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet List'),
      ),
      body: pets.isEmpty
          ? const Center(child: Text('No pets added yet.'))
          : ListView.builder(
              itemCount: pets.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.pets),
                    title: Text(pets[index]['name'] ?? 'Unknown'),
                    subtitle: Text('Age: ${pets[index]['age'] ?? 'Unknown'}'),
                    trailing: PopupMenuButton<Menu>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (Menu item) {
                        _handleMenuSelection(item, index);
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<Menu>>[
                        const PopupMenuItem<Menu>(
                          value: Menu.edit,
                          child: ListTile(
                            leading: Icon(Icons.edit_sharp),
                            title: Text('Edit'),
                          ),
                        ),
                        const PopupMenuItem<Menu>(
                          value: Menu.remove,
                          child: ListTile(
                            leading: Icon(Icons.remove),
                            title: Text('Remove'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(
            () => PetProfile(
              petData: null, // Indicate this is a new pet
              onSave: (newPet) {
                setState(() {
                  pets.add(newPet); // Add the new pet to the list
                });
              },
            ),
          );
        },
        child: const Icon(Icons.add)
      ),
      
    );
  }
}
