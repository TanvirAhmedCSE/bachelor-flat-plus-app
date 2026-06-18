class MealModel {
  final String id;
  final String userId;
  final String userName;
  final int year;
  final int month;
  final int day;
  final int count; // 0, 1, 2, 3...

  MealModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.year,
    required this.month,
    required this.day,
    required this.count,
  });

  factory MealModel.fromMap(Map<String, dynamic> map) {
    return MealModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      year: map['year'] ?? 0,
      month: map['month'] ?? 0,
      day: map['day'] ?? 0,
      count: map['count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'year': year,
      'month': month,
      'day': day,
      'count': count,
    };
  }
}
