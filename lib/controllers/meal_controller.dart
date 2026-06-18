import 'package:uuid/uuid.dart';
import '../services/firestore_service.dart';
import '../models/meal_model.dart';
import '../models/activity_log_model.dart';

class MealController {
  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month];
  }

  Future<void> setMeal({
    required String flatId,
    required String userId,
    required String userName,
    required int year,
    required int month,
    required int day,
    required int count,
  }) async {
    final id = '${userId}_${year}_${month}_$day';
    final meal = MealModel(
      id: id,
      userId: userId,
      userName: userName,
      year: year,
      month: month,
      day: day,
      count: count,
    );
    await FirestoreService.setMeal(flatId, meal);

    final log = ActivityLogModel(
      id: const Uuid().v4(),
      type: 'meal_update',
      by: userId,
      byName: userName,
      message:
          '$userName updated meal ($day ${_monthName(month)} → $count meals)',
      timestamp: DateTime.now(),
    );
    await FirestoreService.logActivity(flatId, log);
  }
}
