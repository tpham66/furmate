import 'package:uuid/uuid.dart';

class Event {
  final String id;
  final String type;
  final String petId;
  final String petName;
  final String person;
  final DateTime time;

  Event({
    required this.id,
    required this.type,
    required this.petId,
    required this.petName,
    required this.person,
    required this.time,
  });

  factory Event.fromMap(Map<String, dynamic> data) {
    return Event(
      id: data['id'] ?? const Uuid().v4(),
      type: data['type'] ?? '',
      petId: data['petId'] ?? '',
      petName: data['petName'] ?? data['pet'] ?? '',
      person: data['person'] ?? '',
      time: DateTime.parse(data['time']),
    );
  }

  Map<String, String> toMap() {
    return {
      'id': id,
      'type': type,
      'petId': petId,
      'petName': petName,
      'person': person,
      'time': time.toIso8601String(),
    };
  }

  Event copyWith({
    String? id,
    String? type,
    String? petId,
    String? petName,
    String? person,
    DateTime? time,
  }) {
    return Event(
      id: id ?? this.id,
      type: type ?? this.type,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      person: person ?? this.person,
      time: time ?? this.time,
    );
  }
}
