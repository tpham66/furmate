class Expense {
  final String id;
  final String petId;
  final String category;
  final String description;
  final double amount;
  final DateTime date;

  Expense({
    required this.id,
    required this.petId,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
  });
}