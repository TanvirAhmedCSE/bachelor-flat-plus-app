class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String addedBy;
  final String addedByName;
  final String category;
  final DateTime date;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.addedBy,
    required this.addedByName,
    required this.category,
    required this.date,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      addedBy: map['addedBy'] ?? '',
      addedByName: map['addedByName'] ?? '',
      category: map['category'] ?? 'other',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'addedBy': addedBy,
      'addedByName': addedByName,
      'category': category,
      'date': date.toIso8601String(),
    };
  }
}
