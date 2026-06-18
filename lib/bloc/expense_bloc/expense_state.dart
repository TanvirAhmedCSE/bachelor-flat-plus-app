part of 'expense_bloc.dart';

abstract class ExpenseState {}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseReady extends ExpenseState {
  final UserModel currentUser;
  final List<UserModel> members;
  final String selectedCategory;
  final String selectedMember; // 'All' or uid
  final int selectedMonth; // 0 = all

  ExpenseReady({
    required this.currentUser,
    required this.members,
    required this.selectedCategory,
    required this.selectedMember,
    required this.selectedMonth,
  });

  ExpenseReady copyWith({
    List<UserModel>? members,
    String? selectedCategory,
    String? selectedMember,
    int? selectedMonth,
  }) {
    return ExpenseReady(
      currentUser: currentUser,
      members: members ?? this.members,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedMember: selectedMember ?? this.selectedMember,
      selectedMonth: selectedMonth ?? this.selectedMonth,
    );
  }
}

class ExpenseFailure extends ExpenseState {
  final String message;
  ExpenseFailure(this.message);
}
