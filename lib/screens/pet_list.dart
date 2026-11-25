import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:furmate/screens/pet_dashboard.dart';
import 'package:material_ui/material_ui.dart';
import 'package:furmate/screens/pet_profile.dart';
import '../data/pet.dart';
import 'dart:io';

import '../widgets/general/image.dart';

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
      pets = snapshot.docs
        .where((doc) => doc.data()['isDeleted'] != true)
        .map((doc) {
          return Pet.fromMap({
            ...doc.data(),
            'id': doc.id,
          });
        })
        .toList();
    });
  }

  void _handleMenuSelection(Menu item, int index) async {
    switch (item) {
      case Menu.edit:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PetProfile(
              petData: pets[index],
              onSave: (updatedPet) async {
                final petRef = FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('pets')
                    .doc(updatedPet.id);
                await petRef.set(
                  updatedPet.toMap(),
                  SetOptions(merge: true),
                );
              },
            ),
          ),
        );
        
        break;

      case Menu.remove:
        _confirmDelete(pets[index]);
        break;
    }
  }

  Future<void> deletePet(Pet pet) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .doc(pet.id)
          .update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Failed to delete pet: $e');
    }
  }

  Future<void> _confirmDelete(Pet pet) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${pet.name}?'),
        content: const Text(
          'This pet will be removed from your active pets. '
          'Its information and activity history will be securely retained, '
          'but won''t be visible in the app. '
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await deletePet(pet);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${pet.name} has been archived'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to archive pet: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mates'),
      ),
      body: pets.isEmpty
          ? const Center(child: Text('No pets added yet.'))
          : ListView.builder(
            padding: EdgeInsets.all(20),
              itemCount: pets.length,
              itemBuilder: (context, index) {
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => PetDashboard(pet: pets[index]))
                      );
                    },
                    leading: CustomImage(
                          id: pets[index].id,
                          imagePath: pets[index].imagePath,
                          size: 30,
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PetProfile(
                onSave: (pet) async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('pets')
                      .doc(pet.id)
                      .set(pet.toMap());
                }
              )
            )
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
