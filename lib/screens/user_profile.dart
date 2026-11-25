import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:furmate/widgets/general/image.dart';
import 'package:material_ui/material_ui.dart';
import '../widgets/general/image_picker.dart';
import 'dart:typed_data';
import '../services/images_service.dart';
import 'package:image_picker/image_picker.dart';

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
  XFile? _selectedImage;
  final ImageService _imageService = ImageService();
  bool _isSaving = false;
  String _profileImagePath = '';

  Future<void> _pickImage() async {
    try {
      final selectedImage =
          await _imagePickerService.pickImageFromGallery();

      if (selectedImage == null) return;

      final bytes = await selectedImage.readAsBytes();

      if (!mounted) return;

      setState(() {
        _selectedImage = selectedImage;
        _imageBytes = bytes;
      });
    } catch (e) {
      debugPrint('Image picker error: $e');
    }
  }

  Future<void> _loadProfileImage() async {
    try {
      final bytes = await _imageService.getUserImage();

      if (!mounted || _selectedImage != null) return;

      setState(() {
        _imageBytes = bytes;
      });
    } catch (e) {
      // No uploaded profile picture yet is normal.
      debugPrint('Profile image load: $e');
    }
  }
  Future<void> _loadProfileData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!mounted) return;

      final data = doc.data();

      setState(() {
        _profileImagePath =
            (data?['profileImagePath'] as String?) ?? '';
      });

      _phoneController.text =
          (data?['phoneNumber'] as String?) ??
          currentUser.phoneNumber ??
          '';

      _locationController.text =
          (data?['location'] as String?) ?? '';

      if (data?['profileImagePath'] == '/api/users/me/image') {
        await _loadProfileImage();
      }
    } catch (e) {
      debugPrint('Profile data load failed: $e');
    }
}

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user data
    _nameController.text = user?.displayName ?? "Username";
    _phoneController.text = user?.phoneNumber ?? "+ 123 456 7890";
    _locationController.text = "City, Country"; // Replace with actual location if available
    _loadProfileData();  
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
                  _imageBytes != null
                  ? CircleAvatar(
                      radius: 50,
                      backgroundImage: MemoryImage(_imageBytes!),
                  )
                  : CustomImage(
                      id: user!.uid,
                      imagePath: _profileImagePath,
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
                  _isSaving ? null : _updateProfile();
                },
                child: _isSaving ? const CircularProgressIndicator() : const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _updateProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || _isSaving) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final location = _locationController.text.trim();

    setState(() => _isSaving = true);

    try {
      String? imagePath;

      // Upload to Cloudflare R2 only when a new photo is selected.
      if (_selectedImage != null) {
        imagePath = await _imageService.uploadUserImage(
          _selectedImage!,
        );
      }

      if (name.isNotEmpty &&
          name != currentUser.displayName) {
        await currentUser.updateDisplayName(name);
      }

      final updates = <String, dynamic>{
        'phoneNumber': phone,
        'location': location,
      };

      if (imagePath != null) {
        updates['profileImagePath'] = imagePath;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set(updates, SetOptions(merge: true));

      await currentUser.reload();

      if (!mounted) return;

      setState(() {
        user = FirebaseAuth.instance.currentUser;
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint('Failed to update profile: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
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
