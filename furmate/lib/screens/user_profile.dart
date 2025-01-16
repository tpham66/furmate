import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/image_picker.dart';
import 'dart:io'; // For working with files


class UserProfile extends StatefulWidget {
  const UserProfile({super.key});
  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  // final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;

  final ImagePickerService _imagePickerService = ImagePickerService();
  File? _image;

  Future<void> _pickImage() async {
    File? selectedImage = await _imagePickerService.pickImageFromGallery();
    if (selectedImage != null) {
      setState(() {
        _image = selectedImage;
      });
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
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : null,
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
                          onPressed: () {
                            // Add your image picker function here
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
                },
                child: Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateProfile() {
    User? user = FirebaseAuth.instance.currentUser;

    // Update user profile data (this requires Firebase update logic)
    // user?.updateDisplayName(_nameController.text);
    user?.updatePhoneNumber(
      _phoneController.text as PhoneAuthCredential); // Phone update will require verification

    // You may also want to display a confirmation or error message here.
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    // _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

}
