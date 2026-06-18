import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<HomeUserLoaded>(_onUserLoaded);
    on<HomeJoinRequestSubmitted>(_onJoinRequestSubmitted);
  }

  Future<void> _onUserLoaded(
    HomeUserLoaded event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    final user = await AuthService.getCurrentUserModel();
    if (user == null || user.isRemoved) {
      emit(HomeUserRemoved());
    } else if (user.isPending) {
      emit(HomeUserPending(user));
    } else {
      emit(HomeUserActive(user));
    }
  }

  Future<void> _onJoinRequestSubmitted(
    HomeJoinRequestSubmitted event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    final error = await AuthService.submitJoinRequest(flatCode: event.flatCode);
    if (error != null) {
      emit(HomeFailure(error));
    } else {
      emit(HomeJoinRequestSent());
    }
  }
}
