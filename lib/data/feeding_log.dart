
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedingLog {
  final String id;
  final String petId;
  final String foodName;
  final String mealType;
  final double quantity;
  final String unit;
  final double? calories;
  final DateTime fedAt;
  final String fedByUid;

  const FeedingLog({
    required this.id,
    required this.petId,
    required this.foodName,
    required this.mealType,
    required this.quantity,
    required this.unit,
    this.calories,
    required this.fedAt,
    required this.fedByUid,
  });

  factory FeedingLog.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return FeedingLog(
      id: doc.id,
      petId: data['petId'] as String,
      foodName: data['foodName'] as String,
      mealType: data['mealType'] as String,
      quantity: (data['quantity'] as num).toDouble(),
      unit: data['unit'] as String,
      calories: (data['calories'] as num?)?.toDouble(),
      fedAt: (data['fedAt'] as Timestamp).toDate(),
      fedByUid: data['fedByUid'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'petId': petId,
      'foodName': foodName,
      'mealType': mealType,
      'quantity': quantity,
      'unit': unit,
      'calories': calories,
      'fedAt': Timestamp.fromDate(fedAt),
      'fedByUid': fedByUid,
    };
  }
}
