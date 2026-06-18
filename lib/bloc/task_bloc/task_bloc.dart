import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user_model.dart';
import '../../models/task_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../controllers/task_controller.dart';
part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  StreamSubscription<List<TaskModel>>? _taskSub;
  StreamSubscription<List<UserModel>>? _memberSub;

  TaskBloc() : super(TaskInitial()) {
    on<TaskInitialized>(_onInitialized);
    on<TaskCompleted>(_onCompleted);
    on<TaskAdded>(_onAdded);
  }

  Future<void> _onInitialized(
    TaskInitialized event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    final user = await AuthService.getCurrentUserModel();
    if (user == null) {
      emit(TaskFailure('User not found'));
      return;
    }

    final members = await FirestoreService.getMembers(user.flatId).first;

    await emit.forEach<List<TaskModel>>(
      FirestoreService.getTasks(user.flatId),
      onData: (tasks) {
        return TaskReady(currentUser: user, members: members, tasks: tasks);
      },
    );
  }

  Future<void> _onCompleted(
    TaskCompleted event,
    Emitter<TaskState> emit,
  ) async {
    final current = state;
    if (current is! TaskReady) return;
    final ctrl = TaskController();
    await ctrl.completeTask(
      current.currentUser.flatId,
      event.task.id,
      current.currentUser.uid,
      current.currentUser.name,
      event.task.title,
      event.task.createdByName,
    );
  }

  Future<void> _onAdded(TaskAdded event, Emitter<TaskState> emit) async {
    final current = state;
    if (current is! TaskReady) return;
    final ctrl = TaskController();
    await ctrl.addTask(
      flatId: current.currentUser.flatId,
      title: event.title,
      description: event.description,
      createdBy: current.currentUser.uid,
      createdByName: current.currentUser.name,
      dueDate: event.dueDate,
      assignedTo: event.assignedTo,
      assignedToNames: event.assignedToNames,
    );
  }

  @override
  Future<void> close() {
    _taskSub?.cancel();
    _memberSub?.cancel();
    return super.close();
  }
}
