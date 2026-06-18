import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../controllers/expense_controller_headless.dart';

part 'expense_event.dart';
part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  ExpenseBloc() : super(ExpenseInitial()) {
    on<ExpenseInitialized>(_onInitialized);
    on<ExpenseCategoryChanged>(_onCategoryChanged);
    on<ExpenseMemberChanged>(_onMemberChanged);
    on<ExpenseMonthChanged>(_onMonthChanged);
    on<ExpenseAdded>(_onExpenseAdded);
  }

  Future<void> _onInitialized(
    ExpenseInitialized event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    final user = await AuthService.getCurrentUserModel();
    if (user == null) {
      emit(ExpenseFailure('User not found'));
      return;
    }
    final members = await FirestoreService.getMembers(user.flatId).first;
    emit(
      ExpenseReady(
        currentUser: user,
        members: members,
        selectedCategory: 'All',
        selectedMember: 'All',
        selectedMonth: 0,
      ),
    );
  }

  void _onCategoryChanged(
    ExpenseCategoryChanged event,
    Emitter<ExpenseState> emit,
  ) {
    final current = state;
    if (current is ExpenseReady) {
      emit(current.copyWith(selectedCategory: event.category));
    }
  }

  void _onMemberChanged(
    ExpenseMemberChanged event,
    Emitter<ExpenseState> emit,
  ) {
    final current = state;
    if (current is ExpenseReady) {
      emit(current.copyWith(selectedMember: event.memberUid));
    }
  }

  void _onMonthChanged(ExpenseMonthChanged event, Emitter<ExpenseState> emit) {
    final current = state;
    if (current is ExpenseReady) {
      emit(current.copyWith(selectedMonth: event.month));
    }
  }

  Future<void> _onExpenseAdded(
    ExpenseAdded event,
    Emitter<ExpenseState> emit,
  ) async {
    final current = state;
    if (current is! ExpenseReady) return;

    final ctrl = ExpenseControllerHeadless();
    await ctrl.addExpense(
      flatId: current.currentUser.flatId,
      title: event.title,
      amount: event.amount,
      category: event.category,
      userId: current.currentUser.uid,
      userName: current.currentUser.name,
    );
  }
}
