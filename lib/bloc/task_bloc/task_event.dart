part of 'task_bloc.dart';

abstract class TaskEvent {}

class TaskInitialized extends TaskEvent {}

class TaskCompleted extends TaskEvent {
  final TaskModel task;
  TaskCompleted(this.task);
}

class TaskAdded extends TaskEvent {
  final String title;
  final String description;
  final DateTime dueDate;
  final List<String> assignedTo;
  final List<String> assignedToNames;
  TaskAdded({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.assignedTo,
    required this.assignedToNames,
  });
}
