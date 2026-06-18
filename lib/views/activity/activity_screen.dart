import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/activity_log_model.dart';
import '../../models/user_model.dart';
import '../../app/theme.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});
  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  UserModel? _currentUser;
  String _filter = 'all';

  final _filters = [
    {'value': 'all', 'label': 'All'},
    {'value': 'notice_add', 'label': 'Notices'},
    {'value': 'expense_add', 'label': 'Expenses'},
    {'value': 'meal_update', 'label': 'Meals'},
    {'value': 'bazar', 'label': 'Bazar List'},
    {'value': 'task_create', 'label': 'Tasks'},
    {'value': 'task_complete', 'label': 'Completed'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUserModel();
    if (mounted) setState(() => _currentUser = user);
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'notice_add':
        return Icons.campaign_rounded;
      case 'expense_add':
        return Icons.account_balance_wallet_rounded;
      case 'meal_update':
        return Icons.restaurant_rounded;
      case 'bazar_add':
      case 'bazar_update':
        return Icons.shopping_cart_rounded;
      case 'task_create':
        return Icons.task_alt_rounded;
      case 'task_complete':
        return Icons.check_circle_rounded;
      case 'member_add':
        return Icons.person_add_rounded;
      case 'admin_transfer':
        return Icons.swap_horiz_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'notice_add':
        return AppColors.info;
      case 'expense_add':
        return AppColors.success;
      case 'meal_update':
        return AppColors.warning;
      case 'bazar_add':
      case 'bazar_update':
        return AppColors.accent;
      case 'task_create':
        return const Color(0xFF9B72CF);
      case 'task_complete':
        return AppColors.success;
      case 'member_add':
        return AppColors.primary;
      case 'admin_transfer':
        return AppColors.secondary;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Activity Log',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 7),
          //  Filter chips
          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filters.length,
              itemBuilder: (_, i) {
                final f = _filters[i];
                final isSelected = _filter == f['value'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = f['value']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.customWhite,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.divider,
                        ),
                      ),
                      child: Text(
                        f['label']!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          //  Activity list
          Expanded(
            child: StreamBuilder<List<ActivityLogModel>>(
              stream: _currentUser == null
                  ? const Stream.empty()
                  : FirestoreService.getActivityLogs(
                      _currentUser!.flatId,
                      type: _filter == 'all' ? null : _filter,
                    ),
              builder: (context, snap) {
                if (_currentUser == null ||
                    snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (!snap.hasData || snap.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 56,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No activity yet',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }
                final logs = snap.data!;
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: logs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final log = logs[i];
                    final isMe = log.by == _currentUser?.uid;
                    final color = _colorFor(log.type);

                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.customWhite,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppColors.otherShadow,
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _iconFor(log.type),
                              color: color,
                              size: 19,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  log.message,
                                  style: TextStyle(
                                    fontWeight: isMe
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat(
                                    'dd MMM yyyy • hh:mm a',
                                  ).format(log.timestamp),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textHint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'You',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
