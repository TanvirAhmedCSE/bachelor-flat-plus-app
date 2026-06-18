part of 'expense_bloc.dart';

abstract class ExpenseEvent {}

class ExpenseInitialized extends ExpenseEvent {}

class ExpenseCategoryChanged extends ExpenseEvent {
  final String category;
  ExpenseCategoryChanged(this.category);
}

class ExpenseMemberChanged extends ExpenseEvent {
  final String memberUid; // 'All' or uid
  ExpenseMemberChanged(this.memberUid);
}

class ExpenseMonthChanged extends ExpenseEvent {
  final int month; // 0 = all
  ExpenseMonthChanged(this.month);
}

class ExpenseAdded extends ExpenseEvent {
  final String title;
  final double amount;
  final String category;
  ExpenseAdded({
    required this.title,
    required this.amount,
    required this.category,
  });
}
