
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class NutritionService {
  static const String baseUrl = 'https://furmate-nutrition-api.furmate.workers.dev';

  Future<List<dynamic>> searchFood(String query) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User is not singed in yet.');

    final token = await user.getIdToken();
    if (token == null) throw Exception('Unable to obtain authentication token.');

    final uri = Uri.parse(
      '$baseUrl/api/nutrition/search',
    ).replace(queryParameters: {
      'q': query.trim(),
    });

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Food search failed: ${response.statusCode}' '${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return data['foods'] as List<dynamic>? ?? [];
  }

  double calculateCalories({
    required double grams,
    required double kcalPer100g,
  }) {
    return grams * kcalPer100g / 100;
  }
}
