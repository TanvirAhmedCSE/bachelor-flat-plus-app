import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/expense_model.dart';
import '../models/activity_log_model.dart';

class ExpenseController {
  final BuildContext context;
  ExpenseController(this.context);

  Future<void> addExpense({
    required String flatId,
    required String title,
    required double amount,
    required String category,
    required String userName,
  }) async {
    final uid = AuthService.currentUser!.uid;
    final expense = ExpenseModel(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      addedBy: uid,
      addedByName: userName,
      category: category,
      date: DateTime.now(),
    );
    await FirestoreService.addExpense(flatId, expense);

    const categoryLabels = {
      'rent': 'Rent',
      'utility': 'Utility',
      'grocery': 'Grocery',
      'event': 'Event',
      'festival bonus': 'Festival Bonus',
      'other': 'Other',
    };
    final categoryLabel = categoryLabels[category] ?? category;

    final log = ActivityLogModel(
      id: const Uuid().v4(),
      type: 'expense_add',
      by: uid,
      byName: userName,
      message:
          '$userName added expense ৳${amount.toStringAsFixed(0)} for $title [$categoryLabel]',
      timestamp: DateTime.now(),
      relatedId: expense.id,
    );
    await FirestoreService.logActivity(flatId, log);
  }
}
