import 'package:uuid/uuid.dart';

class Pet {
  final String id; 
  final String name;
  final String gender;
  final int age;
  final String species;
  final String breed;
  final double weight;
  final String note;
  final String imagePath;

  Pet({
    required this.id,
    required this.name,
    required this.gender,
    required this.age,
    required this.species,
    required this.breed,
    required this.weight,
    required this.note,
    required this.imagePath,
  });

  factory Pet.fromMap(Map<String, dynamic> data) {
    return Pet(
      id: data['id'] ?? Uuid().v4(),
      name: data['name'] ?? '',
      gender: data['gender'] ?? '',
      age: data['age'] ?? 0,
      species: data['species'] ?? '',
      breed: data['breed'] ?? '',
      weight: data['weight'] ?? 0,
      note: data['note'] ?? '',
      imagePath: data['imagePath'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'age': age,
      'species': species,
      'breed': breed,
      'weight': weight,
      'note': note,
      'imagePath': imagePath,
    };
  }

  Pet copyWith({
    String? id,
    String? name,
    String? gender,
    int? age,
    String? species,
    String? breed,
    double? weight,
    String? note,
    String? imagePath,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      weight: weight ?? this.weight,
      note: note ?? this.note,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
