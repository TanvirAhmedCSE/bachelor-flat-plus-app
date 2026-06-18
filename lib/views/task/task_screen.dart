import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/task_bloc/task_bloc.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../app/theme.dart';
import 'task_details_screen.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TaskBloc()..add(TaskInitialized()),
      child: const _TaskView(),
    );
  }
}

class _TaskView extends StatelessWidget {
  const _TaskView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: AppColors.surface,
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              title: const Text(
                'Tasks',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'My Pending'),
                  Tab(text: 'Others'),
                  Tab(text: 'Completed'),
                ],
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
            body: switch (state) {
              TaskLoading() || TaskInitial() => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              TaskFailure(:final message) => Center(child: Text(message)),
              TaskReady(:final currentUser, :final tasks) => _TaskBody(
                currentUser: currentUser,
                tasks: tasks,
              ),
              _ => const SizedBox(),
            },
            floatingActionButton: state is TaskReady
                ? FloatingActionButton(
                    onPressed: () => _showAddTaskDialog(context, state),
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.add, color: Colors.white),
                  )
                : null,
          ),
        );
      },
    );
  }

  void _showAddTaskDialog(BuildContext context, TaskReady state) {
    showDialog(
      context: context,
      builder: (_) => _AddTaskDialog(
        members: state.members,
        onAdd: (title, desc, due, uids, names) {
          context.read<TaskBloc>().add(
            TaskAdded(
              title: title,
              description: desc,
              dueDate: due,
              assignedTo: uids,
              assignedToNames: names,
            ),
          );
        },
      ),
    );
  }
}

class _TaskBody extends StatelessWidget {
  final UserModel currentUser;
  final List<TaskModel> tasks;

  const _TaskBody({required this.currentUser, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final myUid = currentUser.uid;

    final myPending = tasks
        .where(
          (t) => t.assignedTo.contains(myUid) && !t.completedBy.contains(myUid),
        )
        .toList();

    final othersPending = tasks
        .where((t) => !t.assignedTo.contains(myUid) && t.status == 'pending')
        .toList();

    final completed = tasks
        .where((t) => t.completedBy.contains(myUid))
        .toList();

    return TabBarView(
      children: [
        _TaskList(
          tasks: myPending,
          showDoneButton: true,
          emptyText: 'No pending tasks for you',
          onDone: (t) => context.read<TaskBloc>().add(TaskCompleted(t)),
        ),
        _TaskList(
          tasks: othersPending,
          showDoneButton: false,
          emptyText: 'No pending tasks for others',
          onDone: (_) {},
        ),
        _CompletedList(tasks: completed),
      ],
    );
  }
}

//  Task List

class _TaskList extends StatelessWidget {
  final List<TaskModel> tasks;
  final bool showDoneButton;
  final String emptyText;
  final void Function(TaskModel) onDone;

  const _TaskList({
    required this.tasks,
    required this.showDoneButton,
    required this.emptyText,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.task_alt_rounded, size: 56, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(
              emptyText,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final t = tasks[i];
        final isOverdue =
            t.dueDate.isBefore(DateTime.now()) && t.status == 'pending';
        final accentColor = isOverdue ? AppColors.error : AppColors.info;

        return GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            '/task-details',
            arguments: {
              'task': t,
              'mode': showDoneButton
                  ? TaskViewMode.myPending
                  : TaskViewMode.others,
              'onDone': showDoneButton ? () => onDone(t) : null,
            },
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.customWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.secondaryShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.pending_rounded,
                      color: accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (t.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            t.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            _infoChip(
                              Icons.person_outline_rounded,
                              t.createdByName,
                              AppColors.textSecondary,
                            ),
                            _infoChip(
                              Icons.calendar_today_rounded,
                              DateFormat('dd MMM').format(t.dueDate),
                              isOverdue
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                              bold: isOverdue,
                            ),
                            if (t.assignedToNames.isNotEmpty)
                              _infoChip(
                                Icons.assignment_ind_outlined,
                                t.assignedToNames.join(', '),
                                AppColors.info,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (showDoneButton) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => onDone(t),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textWhite,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CompletedList extends StatelessWidget {
  final List<TaskModel> tasks;
  const _CompletedList({required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 56,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 12),
            const Text(
              'No completed tasks',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final t = tasks[i];
        return GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            '/task-details',
            arguments: {
              'task': t,
              'mode': TaskViewMode.completed,
              'onDone': null,
            },
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.customWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.secondaryShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.success,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (t.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            t.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            _infoChip(
                              Icons.person_outline_rounded,
                              t.createdByName,
                              AppColors.textHint,
                            ),
                            _infoChip(
                              Icons.calendar_today_rounded,
                              DateFormat('dd MMM').format(t.dueDate),
                              AppColors.textHint,
                            ),
                            if (t.assignedToNames.isNotEmpty)
                              _infoChip(
                                Icons.assignment_ind_outlined,
                                t.assignedToNames.join(', '),
                                AppColors.textHint,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget _infoChip(
  IconData icon,
  String label,
  Color color, {
  bool bold = false,
}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 11, color: color),
      const SizedBox(width: 3),
      Flexible(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
          softWrap: true,
        ),
      ),
    ],
  );
}

//  Add Task Dialog

class _AddTaskDialog extends StatefulWidget {
  final List<UserModel> members;
  final void Function(
    String title,
    String desc,
    DateTime due,
    List<String> uids,
    List<String> names,
  )
  onAdd;

  const _AddTaskDialog({required this.members, required this.onAdd});

  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  final Set<String> _selectedUids = {};
  bool _selectAll = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _toggleAll(bool? val) {
    setState(() {
      _selectAll = val ?? false;
      if (_selectAll) {
        _selectedUids.addAll(widget.members.map((m) => m.uid));
      } else {
        _selectedUids.clear();
      }
    });
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty) return;
    final names = widget.members
        .where((m) => _selectedUids.contains(m.uid))
        .map((m) => m.name)
        .toList();
    widget.onAdd(
      _titleCtrl.text.trim(),
      _descCtrl.text.trim(),
      _dueDate,
      _selectedUids.toList(),
      names,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.customWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.task_alt_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Add Task',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            // Due date picker
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dueDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _dueDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Due: ${DateFormat('dd MMM yyyy').format(_dueDate)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'ASSIGN TO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Select All',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              value: _selectAll,
              onChanged: _toggleAll,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.primary,
            ),
            ...widget.members.map((m) {
              final isSelected = _selectedUids.contains(m.uid);
              return CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  m.name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                value: isSelected,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedUids.add(m.uid);
                    } else {
                      _selectedUids.remove(m.uid);
                      _selectAll = false;
                    }
                    if (_selectedUids.length == widget.members.length) {
                      _selectAll = true;
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.primary,
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
