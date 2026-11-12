import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/general/image_picker.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});
  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;

  final ImagePickerService _imagePickerService = ImagePickerService();
  Uint8List? _imageBytes;

  Future<void> _pickImage() async {
    try {
      final selectedImage = await _imagePickerService.pickImageFromGallery();
      if (selectedImage == null) return;
      final bytes = await selectedImage.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
      });
    } catch (e) {
      debugPrint('Image picker error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user data
    // _nameController.text = user?.displayName ?? "Username";
    _phoneController.text = user?.phoneNumber ?? "+ 123 456 7890";
    _locationController.text = "City, Country"; // Replace with actual location if available
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = user?.photoURL;
    final hasValidPhotoUrl = photoUrl != null && photoUrl.startsWith('https://');
    return Scaffold(
      appBar: AppBar(title: Text('User Profile')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.black,
                    backgroundImage: _imageBytes != null
                        ? MemoryImage(_imageBytes!)
                        : hasValidPhotoUrl
                          ? NetworkImage(photoUrl)
                          : null,
                    child: _imageBytes == null && !hasValidPhotoUrl ? const Icon(Icons.person, size: 50, color: Colors.white): null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.white, // Background color for the icon
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: IconButton(
                          icon: Icon(Icons.camera_alt, color: Colors.black),
                          iconSize: 20,
                          tooltip: 'Change Profile Picture',
                          onPressed: () {
                            // Add your image picker function here
                            _pickImage();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(user?.displayName ?? "Username", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Divider(height: 30),
              
              ListTile(
                leading: Icon(Icons.email),
                title: Text(user?.email ?? 'user@example.com'),
              ),
              ListTile(
                leading: Icon(Icons.phone),
                title: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                ),
              ),
              ListTile(
                leading: Icon(Icons.location_on),
                title: TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(labelText: 'Location', hintText: 'City, Country'),
                ),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  // Add edit functionality
                  _updateProfile();
                },
                child: Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final location = _locationController.text.trim();
    
    try {
      // Image storage is not available as Firebase Storage is not free
      if (name.isNotEmpty && name != user.displayName) await user.updateDisplayName(name);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
            'phoneNumber': phone,
            'location': location,
          }, SetOptions(merge: true));
      await user.reload();

      if (!mounted) return;

      setState(() {
        this.user = FirebaseAuth.instance.currentUser;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
        ),
      );
      Get.back();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: ${e.message}'),
        ),
      );
    }
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

}
