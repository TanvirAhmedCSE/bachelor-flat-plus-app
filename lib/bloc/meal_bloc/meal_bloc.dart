import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../controllers/meal_controller.dart';

part 'meal_event.dart';
part 'meal_state.dart';

class MealBloc extends Bloc<MealEvent, MealState> {
  final MealController _mealController = MealController();

  MealBloc() : super(MealInitial()) {
    on<MealInitialized>(_onInitialized);
    on<MealMonthChanged>(_onMonthChanged);
    on<MealCountUpdated>(_onCountUpdated);
  }

  Future<void> _onInitialized(
    MealInitialized event,
    Emitter<MealState> emit,
  ) async {
    emit(MealLoading());
    final user = await AuthService.getCurrentUserModel();
    if (user == null) {
      emit(MealFailure('User not found'));
      return;
    }
    final members = await FirestoreService.getMembers(user.flatId).first;
    emit(
      MealReady(
        currentUser: user,
        members: members,
        selectedMonth: DateTime.now().month,
        selectedYear: DateTime.now().year,
      ),
    );
  }

  Future<void> _onMonthChanged(
    MealMonthChanged event,
    Emitter<MealState> emit,
  ) async {
    final current = state;
    if (current is MealReady) {
      emit(
        current.copyWith(selectedMonth: event.month, selectedYear: event.year),
      );
    }
  }

  Future<void> _onCountUpdated(
    MealCountUpdated event,
    Emitter<MealState> emit,
  ) async {
    final current = state;
    if (current is! MealReady) return;

    await _mealController.setMeal(
      flatId: current.currentUser.flatId,
      userId: current.currentUser.uid,
      userName: current.currentUser.name,
      year: current.selectedYear,
      month: current.selectedMonth,
      day: event.day,
      count: event.count,
    );
  }
}
