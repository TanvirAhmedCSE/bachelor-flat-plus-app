part of 'bazar_bloc.dart';

abstract class BazarState {}

class BazarInitial extends BazarState {}

class BazarLoading extends BazarState {}

class BazarFailure extends BazarState {
  final String message;
  BazarFailure(this.message);
}

class BazarReady extends BazarState {
  final String flatId;
  final List<BazarListModel> bazarLists;
  final int selectedMonth;

  BazarReady({
    required this.flatId,
    required this.bazarLists,
    required this.selectedMonth,
  });

  BazarReady copyWith({List<BazarListModel>? bazarLists, int? selectedMonth}) {
    return BazarReady(
      flatId: flatId,
      bazarLists: bazarLists ?? this.bazarLists,
      selectedMonth: selectedMonth ?? this.selectedMonth,
    );
  }

  List<BazarListModel> get filtered {
    if (selectedMonth == 0) return bazarLists;
    return bazarLists.where((b) => b.bazarDate.month == selectedMonth).toList();
  }
}
