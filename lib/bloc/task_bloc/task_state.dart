part of 'task_bloc.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskFailure extends TaskState {
  final String message;
  TaskFailure(this.message);
}

class TaskReady extends TaskState {
  final UserModel currentUser;
  final List<UserModel> members;
  final List<TaskModel> tasks;

  TaskReady({
    required this.currentUser,
    required this.members,
    required this.tasks,
  });

  TaskReady copyWith({List<TaskModel>? tasks, List<UserModel>? members}) {
    return TaskReady(
      currentUser: currentUser,
      members: members ?? this.members,
      tasks: tasks ?? this.tasks,
    );
  }
}
