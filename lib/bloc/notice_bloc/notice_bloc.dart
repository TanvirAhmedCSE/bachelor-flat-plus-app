import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user_model.dart';
import '../../models/notice_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../controllers/notice_controller.dart';
part 'notice_event.dart';
part 'notice_state.dart';

class NoticeBloc extends Bloc<NoticeEvent, NoticeState> {
  NoticeBloc() : super(NoticeInitial()) {
    on<NoticeInitialized>(_onInitialized);
    on<NoticeCategoryChanged>(_onCategoryChanged);
    on<NoticeMonthChanged>(_onMonthChanged);
    on<NoticeAdded>(_onAdded);
  }

  Future<void> _onInitialized(
    NoticeInitialized event,
    Emitter<NoticeState> emit,
  ) async {
    emit(NoticeLoading());
    final user = await AuthService.getCurrentUserModel();
    if (user == null) {
      emit(NoticeFailure('User not found'));
      return;
    }

    await emit.forEach<List<NoticeModel>>(
      FirestoreService.getNotices(user.flatId),
      onData: (notices) {
        final current = state;
        return NoticeReady(
          currentUser: user,
          notices: notices,
          selectedCategory: current is NoticeReady
              ? current.selectedCategory
              : 'All',
          selectedMonth: current is NoticeReady ? current.selectedMonth : 0,
        );
      },
    );
  }

  void _onCategoryChanged(
    NoticeCategoryChanged event,
    Emitter<NoticeState> emit,
  ) {
    final current = state;
    if (current is NoticeReady) {
      emit(current.copyWith(selectedCategory: event.category));
    }
  }

  void _onMonthChanged(NoticeMonthChanged event, Emitter<NoticeState> emit) {
    final current = state;
    if (current is NoticeReady) {
      emit(current.copyWith(selectedMonth: event.month));
    }
  }

  Future<void> _onAdded(NoticeAdded event, Emitter<NoticeState> emit) async {
    final current = state;
    if (current is! NoticeReady) return;

    emit(NoticeSubmitting());

    final ctrl = NoticeController();
    final error = await ctrl.addNotice(
      flatId: current.currentUser.flatId,
      title: event.title,
      description: event.description,
      category: event.category,
      addedByName: current.currentUser.name,
      imageFiles: event.imageFiles,
    );

    if (error != null) {
      emit(NoticeFailure(error));
      emit(current);
    }
  }
}
