import 'package:uuid/uuid.dart';
import '../services/firestore_service.dart';
import '../models/expense_model.dart';
import '../models/activity_log_model.dart';

class ExpenseControllerHeadless {
  static const _categoryLabels = {
    'rent': 'Rent',
    'utility': 'Utility',
    'grocery': 'Grocery',
    'event': 'Event',
    'festival bonus': 'Festival Bonus',
    'other': 'Other',
  };

  Future<void> addExpense({
    required String flatId,
    required String title,
    required double amount,
    required String category,
    required String userId,
    required String userName,
  }) async {
    final expense = ExpenseModel(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      addedBy: userId,
      addedByName: userName,
      category: category,
      date: DateTime.now(),
    );
    await FirestoreService.addExpense(flatId, expense);

    final categoryLabel = _categoryLabels[category] ?? category;
    final log = ActivityLogModel(
      id: const Uuid().v4(),
      type: 'expense_add',
      by: userId,
      byName: userName,
      message:
          '$userName added expense ৳${amount.toStringAsFixed(0)} for $title [$categoryLabel]',
      timestamp: DateTime.now(),
      relatedId: expense.id,
    );
    await FirestoreService.logActivity(flatId, log);
  }
}
