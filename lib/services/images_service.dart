
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImageService {
  static const String baseUrl =
      'https://furmate-nutrition-api.furmate.workers.dev';

  Future<String> uploadImage({
    required String path,
    required XFile image,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not signed in');

    final token = await user.getIdToken();
    final bytes = await image.readAsBytes();

    if (bytes.isEmpty || bytes.length > 5 * 1024 * 1024) {
      throw Exception('Image must be smaller than 5 MB');
    }

    final uri = Uri.parse('$baseUrl$path');

    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/octet-stream',
      },
      body: bytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Upload failed: ${response.statusCode}');
    }

    return path;
  }

  Future<Uint8List> getImage(String path) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not signed in');

    final token = await user.getIdToken();

    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Image not found');
    }

    return response.bodyBytes;
  }

  Future<String> uploadPetImage({
    required String petId,
    required XFile image,
  }) {
    return uploadImage(
      path: '/api/pets/${Uri.encodeComponent(petId)}/image',
      image: image,
    );
  }

  Future<String> uploadUserImage(XFile image) {
    return uploadImage(
      path: '/api/users/me/image',
      image: image,
    );
  }

  Future<Uint8List> getPetImage(String petId) {
    return getImage(
      '/api/pets/${Uri.encodeComponent(petId)}/image',
    );
  }

  Future<Uint8List> getUserImage() {
    return getImage('/api/users/me/image');
  }
}
