import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';
import '../../app/theme.dart';

enum TaskViewMode { myPending, others, completed }

class TaskDetailsScreen extends StatelessWidget {
  final TaskModel task;
  final TaskViewMode mode;
  final VoidCallback? onDone;

  const TaskDetailsScreen({
    super.key,
    required this.task,
    required this.mode,
    this.onDone,
  });

  bool get _isCompleted => mode == TaskViewMode.completed;
  bool get _showDone => mode == TaskViewMode.myPending;

  bool get _isOverdue =>
      task.dueDate.isBefore(DateTime.now()) && task.status == 'pending';

  Color get _accentColor => _isCompleted
      ? AppColors.success
      : _isOverdue
      ? AppColors.error
      : AppColors.info;

  IconData get _statusIcon =>
      _isCompleted ? Icons.check_rounded : Icons.pending_rounded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Task Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _accentColor.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(_statusIcon, color: _accentColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isCompleted
                            ? 'Completed'
                            : _isOverdue
                            ? 'Overdue'
                            : 'Pending',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _accentColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isCompleted
                            ? 'This task has been completed'
                            : _isOverdue
                            ? 'Due date has passed'
                            : 'Waiting to be done',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            //  Title & Description
            _sectionLabel('TASK INFO'),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.customWhite,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppColors.otherShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      decoration: _isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: AppColors.textSecondary,
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Divider(color: AppColors.divider),
                    const SizedBox(height: 10),
                    Text(
                      task.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: _isCompleted
                            ? AppColors.textHint
                            : AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            //  Meta Info
            _sectionLabel('DETAILS'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.customWhite,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppColors.otherShadow,
              ),
              child: Column(
                children: [
                  _detailRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Created by',
                    value: task.createdByName,
                    iconColor: AppColors.info,
                  ),
                  _divider(),
                  _detailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Due date',
                    value: DateFormat('dd MMM yyyy').format(task.dueDate),
                    iconColor: _isOverdue && !_isCompleted
                        ? AppColors.error
                        : AppColors.primary,
                    valueColor: _isOverdue && !_isCompleted
                        ? AppColors.error
                        : AppColors.textPrimary,
                    valueBold: _isOverdue && !_isCompleted,
                  ),
                  if (task.assignedToNames.isNotEmpty) ...[
                    _divider(),
                    _detailRow(
                      icon: Icons.assignment_ind_outlined,
                      label: 'Assigned to',
                      value: task.assignedToNames.join(', '),
                      iconColor: AppColors.secondary,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),

            //  Done Button
            if (_showDone)
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    onDone?.call();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text(
                    'Mark as Done',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: AppColors.primary,
      letterSpacing: 1.2,
    ),
  );

  Widget _divider() => const Divider(
    height: 1,
    thickness: 1,
    color: AppColors.divider,
    indent: 16,
    endIndent: 16,
  );

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
    Color iconColor = AppColors.primary,
    Color valueColor = AppColors.textPrimary,
    bool valueBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 17, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: valueColor,
                    fontWeight: valueBold ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
