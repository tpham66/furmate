import 'package:uuid/uuid.dart';

class Event {
  final String id;
  final String type;
  final String pet;
  final String person;
  final DateTime time;

  Event({
    required this.id,
    required this.type,
    required this.pet,
    required this.person,
    required this.time,
  });

  factory Event.fromMap(Map<String, dynamic> data) {
    return Event(
      id: data['id'] ?? const Uuid().v4(),
      type: data['type'] ?? '',
      pet: data['pet'] ?? '',
      person: data['person'] ?? '',
      time: DateTime.parse(data['time']),
    );
  }

  Map<String, String> toMap() {
    return {
      'id': id,
      'type': type,
      'pet': pet,
      'person': person,
      'time': time.toIso8601String(),
    };
  }

  Event copyWith({
    String? id,
    String? type,
    String? pet,
    String? person,
    DateTime? time,
  }) {
    return Event(
      id: id ?? this.id,
      type: type ?? this.type,
      pet: pet ?? this.pet,
      person: person ?? this.person,
      time: time ?? this.time,
    );
  }
}
