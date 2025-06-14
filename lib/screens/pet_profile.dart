import 'package:flutter/material.dart';
import '../widgets/image_picker.dart';
import 'package:get/get.dart';
import 'dart:io';

const List<Widget> genders = <Widget>[
  Text('Female'),
  Text('Male'),
];

class PetProfile extends StatefulWidget {
  final Map<String, String>? petData; // Null for adding a new pet
  final Function(Map<String, String>) onSave; // Callback for saving the pet

  const PetProfile({super.key, this.petData, required this.onSave});

  @override
  PetProfileState createState() => PetProfileState();
}

class PetProfileState extends State<PetProfile> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Key for the form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _speciesController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final ImagePickerService _imagePickerService = ImagePickerService();

  List<bool> _selectedGenders = <bool>[true, false];

  File? _image;

  Future<void> _pickImage() async {
    File? selectedImage = await _imagePickerService.pickImageFromGallery();
    if (selectedImage != null) {
      setState(() {
        _image = selectedImage;
      });
    }
  }

  void _saveForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Form is valid
      widget.onSave({
        'name': _nameController.text,
        'gender': getGender(_selectedGenders),
        'age': _ageController.text,
        'species': _speciesController.text,
        'breed': _breedController.text,
        'weight': _weightController.text,
        'note': _noteController.text,
        'imagePath': _image!.path,
      });
      Get.back(); // Navigate back
    } else {}
  }

  String getGender(List<bool> genders) {
    if (genders[0]) {
      return 'Female';
    } else if (genders[1]) {
      return 'Male';
    }
    return 'Unknown';
  }

  @override
  void initState() {
    super.initState();
    // Initialize controllers with pet data if available
    if (widget.petData != null) {
      _nameController.text = widget.petData!['name'] ?? '';
      _ageController.text = widget.petData!['age'] ?? '';
      _speciesController.text = widget.petData!['species'] ?? '';
      _breedController.text = widget.petData!['breed'] ?? '';
      _weightController.text = widget.petData!['weight'] ?? '';
      _noteController.text = widget.petData!['note'] ?? '';

      // Load the image from the saved path
      if (widget.petData!['imagePath'] != null) {
        _image = File(widget.petData!['imagePath']!);
      }

      // Load the genders
      if (widget.petData!['gender'] == 'Female') {
        _selectedGenders = [true, false];
      } else if (widget.petData!['gender'] == 'Male') {
        _selectedGenders = [false, true];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey, // Wrap all TextFormFields in a Form
            child: Column(
              children: [
                // Image picker section
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage:
                          _image != null ? FileImage(_image!) : null,
                      child: _image == null
                          ? const Icon(Icons.pets, size: 50, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: -10,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.black),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        onPressed: _pickImage,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(),

                // Name field with validation
                ListTile(
                  leading: const Icon(Icons.pets_rounded),
                  title: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name *',
                      hintText: 'Enter your pet\'s name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid name';
                      }
                      return null;
                    },
                  ),
                ),

                // Gender field
                ListTile(
                  leading: Icon(
                      _selectedGenders[0] == false ? Icons.male : Icons.female),
                  title: ToggleButtons(
                    direction: Axis.horizontal,
                    onPressed: (int index) {
                      setState(() {
                        // The button that is tapped is set to true, and the others to false.
                        for (int i = 0; i < _selectedGenders.length; i++) {
                          _selectedGenders[i] = i == index;
                        }
                      });
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    // selectedBorderColor: Colors.red[700],
                    selectedColor: Colors.white,
                    fillColor: Colors.red[200],
                    color: Colors.red[400],
                    constraints: const BoxConstraints(
                      minHeight: 40.0,
                      minWidth: 80.0,
                    ),
                    isSelected: _selectedGenders,
                    children: genders,
                  ),
                ),

                // Age field with validation
                ListTile(
                  leading: const Icon(Icons.date_range),
                  title: TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Age *',
                      hintText: 'Enter your pet\'s age',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the pet\'s age';
                      }
                      if (int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return 'Please enter a valid age';
                      }
                      return null;
                    },
                  ),
                ),

                // Species field with validation
                ListTile(
                  leading: const Icon(Icons.pets),
                  title: TextFormField(
                    controller: _speciesController,
                    decoration: const InputDecoration(
                      labelText: 'Species *',
                      hintText: 'Enter your pet\'s species',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the species';
                      }
                      return null;
                    },
                  ),
                ),

                // Breed field with validation
                ListTile(
                  leading: const Icon(Icons.list),
                  title: TextFormField(
                    controller: _breedController,
                    decoration: const InputDecoration(
                      labelText: 'Breed',
                      hintText: 'Enter your pet\'s breed',
                    ),
                  ),
                ),

                // Weight field with validation
                ListTile(
                  leading: const Icon(Icons.scale_rounded),
                  title: TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.numberWithOptions(),
                    decoration: const InputDecoration(
                      labelText: 'Weight',
                      hintText: 'Enter your pet\'s weight',
                    ),
                  ),
                ),

                // Care note with validation
                ListTile(
                  leading: const Icon(Icons.note),
                  title: TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note',
                      hintText: 'Note for your pet (Optional)',
                    ),
                  ),
                ),

                // Save button
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    splashFactory: InkRipple.splashFactory,
                  ),
                  child: const Text('Save'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
