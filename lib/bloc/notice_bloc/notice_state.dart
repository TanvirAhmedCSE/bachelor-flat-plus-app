part of 'notice_bloc.dart';

abstract class NoticeState {}

class NoticeInitial extends NoticeState {}

class NoticeLoading extends NoticeState {}

class NoticeSubmitting extends NoticeState {}

class NoticeFailure extends NoticeState {
  final String message;
  NoticeFailure(this.message);
}

class NoticeReady extends NoticeState {
  final UserModel currentUser;
  final List<NoticeModel> notices;
  final String selectedCategory;
  final int selectedMonth;

  NoticeReady({
    required this.currentUser,
    required this.notices,
    required this.selectedCategory,
    required this.selectedMonth,
  });

  NoticeReady copyWith({
    List<NoticeModel>? notices,
    String? selectedCategory,
    int? selectedMonth,
  }) {
    return NoticeReady(
      currentUser: currentUser,
      notices: notices ?? this.notices,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedMonth: selectedMonth ?? this.selectedMonth,
    );
  }

  List<NoticeModel> get filtered => notices.where((n) {
    final catOk = selectedCategory == 'All' || n.category == selectedCategory;
    final monthOk = selectedMonth == 0 || n.addedAt.month == selectedMonth;
    return catOk && monthOk;
  }).toList();
}
