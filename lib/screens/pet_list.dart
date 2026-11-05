import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:furmate/screens/pet_profile.dart';
import 'package:get/get.dart';
import '../data/pet.dart';
import 'dart:io';


enum Menu { edit, remove }


class PetList extends StatefulWidget {
  const PetList({super.key});

  @override
  PetListState createState() => PetListState();
}

class PetListState extends State<PetList> {
  List<Pet> pets = [];

  @override
  void initState() {
    super.initState();
    loadPets();
  }

  Future<void> loadPets() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('pets')
      .get();

    setState(() {
      pets = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Pet.fromMap(data);
      }).toList();
    });
  }

  void _handleMenuSelection(Menu item, int index) async {
    switch (item) {
      case Menu.edit:
        Get.to(() => PetProfile(
              petData: pets[index],
              onSave: (updatedPet) async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('pets')
                    .doc(updatedPet.id)
                    .update(updatedPet.toMap());

                setState(() {
                  pets[index] = updatedPet;
                });
              },
            ));
        break;

      case Menu.remove:
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        final petId = pets[index].id;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('pets')
            .doc(petId)
            .delete();

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
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: (pets[index].imagePath.isNotEmpty)
                          ? FileImage(File(pets[index].imagePath))
                          : null,
                      child: (pets[index].imagePath.isEmpty)
                          ? const Icon(Icons.pets, color: Colors.grey)
                          : null,
                    ),
                    title: Text(pets[index].name),
                    subtitle: Text('Age: ${pets[index].age}'),
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
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) return;

              final docRef = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('pets')
                  .add(newPet.toMap());
              final savedPet = newPet.copyWith(id: docRef.id);
              setState(() {
                pets.add(savedPet);
              });
            },
          ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
