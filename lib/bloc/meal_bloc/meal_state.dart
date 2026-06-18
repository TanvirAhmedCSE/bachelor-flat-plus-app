part of 'meal_bloc.dart';

abstract class MealState {}

class MealInitial extends MealState {}

class MealLoading extends MealState {}

class MealReady extends MealState {
  final UserModel currentUser;
  final List<UserModel> members;
  final int selectedMonth;
  final int selectedYear;

  MealReady({
    required this.currentUser,
    required this.members,
    required this.selectedMonth,
    required this.selectedYear,
  });

  MealReady copyWith({
    List<UserModel>? members,
    int? selectedMonth,
    int? selectedYear,
  }) {
    return MealReady(
      currentUser: currentUser,
      members: members ?? this.members,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
    );
  }
}

class MealFailure extends MealState {
  final String message;
  MealFailure(this.message);
}
