import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:furmate/widgets/general/image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import '../widgets/general/image_picker.dart';
import '../services/images_service.dart';
import '../widgets/general/button.dart';
import '../data/pet.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

const List<Widget> genders = <Widget>[
  Text('Female'),
  Text('Male'),
];

const List<Widget> units = <Widget>[
  Text('Kg'),
  Text('Lb'),
];

class PetProfile extends StatefulWidget {
  final Pet? petData;
  final Function(Pet) onSave; // Callback for saving the pet

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

  String weightUnit = 'kg';
  final List<bool> _selectedUnits = [true, false];

  Uint8List? _image;
  XFile? _selectedImage;
  String? _existingImageUrl;

  final ImageService _imageService = ImageService();

  Future<void> _pickImage() async {
    try {
      final selectedImage =
          await _imagePickerService.pickImageFromGallery();

      if (selectedImage == null) return;

      final bytes = await selectedImage.readAsBytes();

      if (!mounted) return;

      setState(() {
        _selectedImage = selectedImage;
        _image = bytes;
      });
    } catch (e) {
      debugPrint('Image picker error: $e');
    }
  }


  Future<void> _saveForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final petId = widget.petData?.id ?? const Uuid().v4();

    String imagePath = widget.petData?.imagePath ?? '';

    try {
      // Save the pet first so its Firestore document exists.
      final data = Pet(
        id: petId,
        name: _nameController.text.trim(),
        gender: getGender(_selectedGenders),
        age: int.tryParse(_ageController.text) ?? 0,
        species: _speciesController.text.trim(),
        breed: _breedController.text.trim(),
        weight: double.tryParse(_weightController.text) ?? 0,
        weightUnit: weightUnit,
        note: _noteController.text.trim(),
        imagePath: imagePath,
      );

      await widget.onSave(data);

      // Upload the new image only if one was selected.
      if (_selectedImage != null) {
        imagePath = await _imageService.uploadPetImage(
          petId: petId,
          image: _selectedImage!,
        );

        // Save the Cloudflare image reference in Firestore.
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('pets')
            .doc(petId)
            .update({
          'imagePath': imagePath,
        });
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Failed to save pet: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save pet: $e'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize controllers with pet data if available
    if (widget.petData != null) {
      _nameController.text = widget.petData!.name;
      _ageController.text = widget.petData!.age.toString();
      _speciesController.text = widget.petData!.species;
      _breedController.text = widget.petData!.breed;
      _weightController.text = widget.petData!.weight.toString();
      _noteController.text = widget.petData!.note;

      // Load the image from the saved path
      _existingImageUrl = widget.petData!.imagePath;
      // Load the genders
      if (widget.petData!.gender == 'Female') {
        _selectedGenders = [true, false];
      } else if (widget.petData!.gender == 'Male') {
        _selectedGenders = [false, true];
      }
    }
  }

  String getGender(List<bool> genders) {
    if (genders[0]) {
      return 'Female';
    } else if (genders[1]) {
      return 'Male';
    } else {
      return 'Unknown';
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
                  clipBehavior: Clip.none,
                  children: [  
                  _image != null
                      ? CircleAvatar(
                          radius: 50,
                          backgroundImage: MemoryImage(_image!),
                        )
                      : CustomImage(
                          id: widget.petData?.id ?? '',
                          imagePath: _existingImageUrl ?? '',
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
                  title: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _weightController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Weight',
                            hintText: 'Enter weight',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ToggleButtons(
                            isSelected: _selectedUnits,
                            direction: Axis.horizontal,
                            onPressed: (int index) {
                              setState(() {
                                for (int i = 0; i < _selectedUnits.length; i++) {
                                  _selectedUnits[i] = i == index;
                                }

                                weightUnit = index == 0 ? 'kg' : 'lbs';
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            selectedColor: Colors.white,
                            fillColor: Colors.red[200],
                            color: Colors.red[400],
                            constraints: const BoxConstraints(
                              minHeight: 40,
                              minWidth: 55,
                            ),
                            children: units,
                          ),
                        ),
                      ),
                    ],
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
                CustomButton(
                  label: 'Save', 
                  onTap: _saveForm, 
                  width: 143, 
                  height: 57
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
