import 'package:flutter/material.dart';
import 'package:furmate/screens/pet_profile.dart';
import 'package:get/get.dart';
import 'dart:io';


enum Menu { edit, remove }


class PetList extends StatefulWidget {
  const PetList({super.key});

  @override
  PetListState createState() => PetListState();
}

class PetListState extends State<PetList> {
  List<Map<String, String>> pets = [];

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
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: (pets[index]['imagePath'] != null &&
                              pets[index]['imagePath']!.isNotEmpty)
                          ? FileImage(File(pets[index]['imagePath']!))
                          : null,
                      child: (pets[index]['imagePath'] == null ||
                              pets[index]['imagePath']!.isEmpty)
                          ? const Icon(Icons.pets, color: Colors.grey)
                          : null,
                    ),
                    title: Text(pets[index]['name'] ?? 'Unknown'),
                    subtitle: Text('Age: ${pets[index]['age'] ?? 'Unknown'}'),
                    trailing: PopupMenuButton<Menu>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (item) => _handleMenuSelection(item, index),
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: Menu.edit,
                          child: ListTile(
                            leading: Icon(Icons.edit_sharp),
                            title: Text('Edit'),
                          ),
                        ),
                        PopupMenuItem(
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
          Get.to(() => PetProfile(
                petData: null,
                onSave: (newPet) async {
                  
                },
              ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
