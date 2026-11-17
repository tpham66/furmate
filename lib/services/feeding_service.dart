
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/feeding_log.dart';

class FeedingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _collection {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('User is not signed in');
    }

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('feeding_logs');
  }

  // Listen to a specific pet's feeding history.
  Stream<List<FeedingLog>> getFeedingLogs(String petId) {
    return _collection
        .where('petId', isEqualTo: petId)
        .snapshots()
        .map((snapshot) {
      final logs = snapshot.docs
          .map(FeedingLog.fromFirestore)
          .toList();

      logs.sort((a, b) => b.fedAt.compareTo(a.fedAt));

      return logs;
    });
  }

  // Create a new feeding record.
  Future<void> addFeedingLog({
    required String petId,
    required String foodName,
    required String mealType,
    required double quantity,
    required String unit,
    double? calories,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('User is not signed in');
    }

    if (quantity <= 0 || !quantity.isFinite) {
      throw ArgumentError('Quantity must be greater than zero');
    }

    if (calories != null &&
        (calories < 0 || !calories.isFinite)) {
      throw ArgumentError('Calories must be valid');
    }

    final doc = _collection.doc();

    final log = FeedingLog(
      id: doc.id,
      petId: petId,
      foodName: foodName.trim(),
      mealType: mealType,
      quantity: quantity,
      unit: unit,
      calories: calories,
      fedAt: DateTime.now(),
      fedByUid: user.uid,
    );

    await doc.set(log.toMap());
  }

  // Delete a feeding record.
  Future<void> deleteFeedingLog(String logId) async {
    await _collection.doc(logId).delete();
  }
}
