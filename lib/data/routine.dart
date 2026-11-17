class PetRoutine {
  final String id;
  final String petId;
  final String type;
  final String frequency;
  final List<int> weekdays;
  final DateTime startDate;
  final DateTime? endDate;
  final int hour;
  final int minute;
  final bool isActive;

  PetRoutine({
    required this.id,
    required this.petId,
    required this.type,
    required this.frequency,
    required this.weekdays,
    required this.startDate,
    this.endDate,
    required this.hour,
    required this.minute,
    required this.isActive,
  });
}