import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/bazar_list_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
part 'bazar_event.dart';
part 'bazar_state.dart';

class BazarBloc extends Bloc<BazarEvent, BazarState> {
  BazarBloc() : super(BazarInitial()) {
    on<BazarInitialized>(_onInitialized);
    on<BazarMonthChanged>(_onMonthChanged);
  }

  Future<void> _onInitialized(
    BazarInitialized event,
    Emitter<BazarState> emit,
  ) async {
    emit(BazarLoading());
    final user = await AuthService.getCurrentUserModel();
    if (user == null) {
      emit(BazarFailure('User not found'));
      return;
    }

    await emit.forEach<List<BazarListModel>>(
      FirestoreService.getBazarLists(user.flatId),
      onData: (list) {
        final current = state;
        return BazarReady(
          flatId: user.flatId,
          bazarLists: list,
          selectedMonth: current is BazarReady ? current.selectedMonth : 0,
        );
      },
    );
  }

  void _onMonthChanged(BazarMonthChanged event, Emitter<BazarState> emit) {
    final current = state;
    if (current is BazarReady) {
      emit(current.copyWith(selectedMonth: event.month));
    }
  }
}
