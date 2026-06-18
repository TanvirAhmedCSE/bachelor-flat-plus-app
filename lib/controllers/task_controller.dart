import 'package:uuid/uuid.dart';
import '../services/firestore_service.dart';
import '../models/task_model.dart';
import '../models/activity_log_model.dart';

class TaskController {
  Future<void> addTask({
    required String flatId,
    required String title,
    required String description,
    required String createdBy,
    required String createdByName,
    required DateTime dueDate,
    required List<String> assignedTo,
    required List<String> assignedToNames,
  }) async {
    final id = const Uuid().v4();
    final task = TaskModel(
      id: id,
      title: title,
      description: description,
      createdBy: createdBy,
      createdByName: createdByName,
      status: 'pending',
      dueDate: dueDate,
      createdAt: DateTime.now(),
      assignedTo: assignedTo,
      assignedToNames: assignedToNames,
      completedBy: [],
    );
    await FirestoreService.addTask(flatId, task);

    final forNames = assignedToNames.isEmpty
        ? 'everyone'
        : assignedToNames.join(', ');

    final log = ActivityLogModel(
      id: const Uuid().v4(),
      type: 'task_create',
      by: createdBy,
      byName: createdByName,
      message: '$createdByName created task "$title" for $forNames',
      timestamp: DateTime.now(),
      relatedId: id,
    );
    await FirestoreService.logActivity(flatId, log);
  }

  Future<void> completeTask(
    String flatId,
    String taskId,
    String userId,
    String userName,
    String taskTitle,
    String createdByName,
  ) async {
    await FirestoreService.completeTask(flatId, taskId, userId);

    await FirestoreService.deleteTaskCompleteLog(flatId, taskId);

    final task = await FirestoreService.getTaskOnce(flatId, taskId);
    if (task == null) return;

    final names = task.assignedToNames.where((name) {
      final idx = task.assignedToNames.indexOf(name);
      return task.completedBy.contains(task.assignedTo[idx]);
    }).toList();

    final formattedNames = _formatNames(names);

    final log = ActivityLogModel(
      id: const Uuid().v4(),
      type: 'task_complete',
      by: userId,
      byName: userName,
      message: '$formattedNames completed task "$taskTitle" by $createdByName',
      timestamp: DateTime.now(),
      relatedId: taskId,
    );
    await FirestoreService.logActivity(flatId, log);
  }

  String _formatNames(List<String> names) {
    if (names.isEmpty) return '';
    if (names.length == 1) return names[0];
    if (names.length == 2) return '${names[0]} and ${names[1]}';
    return '${names.sublist(0, names.length - 1).join(', ')} and ${names.last}';
  }
}
