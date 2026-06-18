import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../bloc/notice_bloc/notice_bloc.dart';
import '../../models/notice_model.dart';
import '../../app/theme.dart';

class NoticeListScreen extends StatelessWidget {
  const NoticeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NoticeBloc()..add(NoticeInitialized()),
      child: const _NoticeView(),
    );
  }
}

class _NoticeView extends StatelessWidget {
  const _NoticeView();

  static const _categories = [
    'All',
    'Grocery',
    'Rent',
    'Essentials',
    'Electricity',
    'Water',
    'Gas',
    'Maid Charge',
    'Event',
    'Festival Bonus',
    'Others',
  ];

  static const _months = [
    'All',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Grocery':
        return Icons.local_grocery_store;
      case 'Rent':
        return Icons.home_rounded;
      case 'Essentials':
        return Icons.bolt_rounded;
      case 'Electricity':
        return Icons.electric_bolt_outlined;
      case 'Water':
        return Icons.water_drop_rounded;
      case 'Gas':
        return Icons.local_fire_department_rounded;
      case 'Maid Charge':
        return Icons.cleaning_services_rounded;
      case 'Event':
        return Icons.event_rounded;
      case 'Festival Bonus':
        return Icons.card_giftcard_rounded;
      default:
        return Icons.campaign_rounded;
    }
  }

  static Color _categoryColor(String cat) {
    switch (cat) {
      case 'Grocery':
        return const Color(0xFF4CAF82);
      case 'Rent':
        return const Color(0xFF5A8FA8);
      case 'Essentials':
        return const Color(0xFFF2A65A);
      case 'Electricity':
        return const Color(0xFF9B72CF);
      case 'Water':
        return const Color(0xFF00BCD4);
      case 'Gas':
        return const Color(0xFFD95F5F);
      case 'Maid Charge':
        return const Color(0xFF7B68EE);
      case 'Event':
        return const Color(0xFFE07A5F);
      case 'Festival Bonus':
        return const Color(0xFFF2A65A);
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoticeBloc, NoticeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            title: const Text(
              'Notices',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              if (state is NoticeReady)
                DropdownButton<int>(
                  value: state.selectedMonth,
                  dropdownColor: AppColors.customWhite,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  selectedItemBuilder: (_) => List.generate(
                    13,
                    (i) => Center(
                      child: Text(
                        _months[i],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  items: List.generate(
                    13,
                    (i) => DropdownMenuItem(
                      value: i,
                      child: Text(
                        _months[i],
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  onChanged: (v) =>
                      context.read<NoticeBloc>().add(NoticeMonthChanged(v!)),
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              const SizedBox(height: 7),
              //  Category chips
              SizedBox(
                height: 52,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (_, i) {
                    final cat = _categories[i];
                    final isSelected =
                        state is NoticeReady && state.selectedCategory == cat;
                    final color = cat == 'All'
                        ? AppColors.primary
                        : _categoryColor(cat);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => context.read<NoticeBloc>().add(
                          NoticeCategoryChanged(cat),
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? color : AppColors.customWhite,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? color : AppColors.divider,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (cat != 'All') ...[
                                Icon(
                                  _categoryIcon(cat),
                                  size: 13,
                                  color: isSelected ? Colors.white : color,
                                ),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(child: _buildBody(context, state)),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: state is NoticeReady
                ? () => _showAddNoticeDialog(context)
                : null,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, NoticeState state) {
    if (state is NoticeLoading || state is NoticeInitial) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (state is NoticeFailure) return Center(child: Text(state.message));
    if (state is! NoticeReady)
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );

    final notices = state.filtered;

    if (notices.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.campaign_outlined, size: 56, color: AppColors.textHint),
            const SizedBox(height: 12),
            const Text(
              'No notices yet',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: notices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final n = notices[i];
        return _NoticeCard(
          notice: n,
          color: _categoryColor(n.category),
          icon: _categoryIcon(n.category),
          onTap: () =>
              Navigator.pushNamed(context, '/notice-details', arguments: n),
        );
      },
    );
  }

  Future<void> _showAddNoticeDialog(BuildContext context) async {
    final bloc = context.read<NoticeBloc>();
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String category = 'Others';
    final List<File> images = [];

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDs) => BlocListener<NoticeBloc, NoticeState>(
          bloc: bloc,
          listener: (_, state) {
            if (state is NoticeReady || state is NoticeFailure) {
              if (ctx.mounted) Navigator.pop(ctx);
            }
          },
          child: BlocBuilder<NoticeBloc, NoticeState>(
            bloc: bloc,
            builder: (_, state) {
              final loading = state is NoticeSubmitting;
              return AlertDialog(
                backgroundColor: AppColors.customWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.campaign_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Add Notice',
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
                        controller: titleCtrl,
                        decoration: const InputDecoration(labelText: 'Title *'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Description (optional)',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: category,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Grocery',
                            child: Text('Grocery'),
                          ),
                          DropdownMenuItem(value: 'Rent', child: Text('Rent')),
                          DropdownMenuItem(
                            value: 'Essentials',
                            child: Text('Essentials'),
                          ),
                          DropdownMenuItem(
                            value: 'Electricity',
                            child: Text('Electricity'),
                          ),
                          DropdownMenuItem(
                            value: 'Water',
                            child: Text('Water'),
                          ),
                          DropdownMenuItem(value: 'Gas', child: Text('Gas')),
                          DropdownMenuItem(
                            value: 'Maid Charge',
                            child: Text('Maid Charge'),
                          ),
                          DropdownMenuItem(
                            value: 'Event',
                            child: Text('Event'),
                          ),
                          DropdownMenuItem(
                            value: 'Festival Bonus',
                            child: Text('Festival Bonus'),
                          ),
                          DropdownMenuItem(
                            value: 'Others',
                            child: Text('Others'),
                          ),
                        ],
                        onChanged: (v) => setDs(() => category = v!),
                      ),
                      const SizedBox(height: 16),
                      if (images.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: images.asMap().entries.map((e) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    e.value,
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () =>
                                        setDs(() => images.removeAt(e.key)),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: AppColors.error,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(2),
                                      child: const Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                      ],
                      OutlinedButton.icon(
                        onPressed: loading
                            ? null
                            : () async {
                                final picker = ImagePicker();
                                final picked = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 75,
                                );
                                if (picked != null)
                                  setDs(() => images.add(File(picked.path)));
                              },
                        icon: const Icon(
                          Icons.add_photo_alternate_rounded,
                          size: 18,
                        ),
                        label: Text(
                          images.isEmpty
                              ? 'Upload Image'
                              : 'Upload Another Image',
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: loading ? null : () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: loading
                        ? null
                        : () {
                            if (titleCtrl.text.trim().isEmpty) return;
                            bloc.add(
                              NoticeAdded(
                                title: titleCtrl.text.trim(),
                                description: descCtrl.text.trim(),
                                category: category,
                                imageFiles: List.from(images),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Post'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

//  Notice Card
class _NoticeCard extends StatelessWidget {
  final NoticeModel notice;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _NoticeCard({
    required this.notice,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.customWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.otherShadow,
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notice.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (notice.imageUrls.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.photo_library_outlined,
                          size: 14,
                          color: AppColors.textHint,
                        ),
                      ],
                    ],
                  ),
                  if (notice.description.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      notice.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  // meta row — category always on its own line
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      notice.category,
                      style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 12,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        notice.addedByName,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        DateFormat('dd MMM yyyy').format(notice.addedAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}
