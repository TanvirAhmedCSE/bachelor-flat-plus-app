part of 'meal_bloc.dart';

abstract class MealEvent {}

class MealInitialized extends MealEvent {}

class MealMonthChanged extends MealEvent {
  final int month;
  final int year;
  MealMonthChanged({required this.month, required this.year});
}

class MealCountUpdated extends MealEvent {
  final int day;
  final int count;
  MealCountUpdated({required this.day, required this.count});
}
