import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/bazar_bloc/bazar_bloc.dart';
import '../../models/bazar_list_model.dart';
import '../../app/theme.dart';

class BazarListScreen extends StatelessWidget {
  const BazarListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BazarBloc()..add(BazarInitialized()),
      child: const _BazarView(),
    );
  }
}

class _BazarView extends StatelessWidget {
  const _BazarView();

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BazarBloc, BazarState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            title: const Text(
              'Bazar Lists',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              if (state is BazarReady)
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
                      context.read<BazarBloc>().add(BazarMonthChanged(v!)),
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: _buildBody(context, state),
          floatingActionButton: FloatingActionButton(
            onPressed: state is BazarReady
                ? () => Navigator.pushNamed(
                    context,
                    '/bazar-create',
                    arguments: {'flatId': (state).flatId},
                  )
                : null,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, BazarState state) {
    if (state is BazarLoading || state is BazarInitial) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (state is BazarFailure) return Center(child: Text(state.message));
    if (state is! BazarReady) return const SizedBox();

    final items = state.filtered;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 56,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 12),
            const Text(
              'No bazar lists yet',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final b = items[i];
        return _BazarListCard(
          bazar: b,
          onTap: () => Navigator.pushNamed(
            context,
            '/bazar-details',
            arguments: {'bazar': b, 'flatId': state.flatId},
          ),
        );
      },
    );
  }
}

class _BazarListCard extends StatelessWidget {
  final BazarListModel bazar;
  final VoidCallback onTap;

  const _BazarListCard({required this.bazar, required this.onTap});

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
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.shopping_basket_rounded,
                color: AppColors.success,
                size: 20,
              ),
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
                          bazar.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (bazar.imageUrls.isNotEmpty)
                        const Icon(
                          Icons.photo_library_outlined,
                          size: 14,
                          color: AppColors.textHint,
                        ),
                    ],
                  ),
                  if (bazar.description.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      bazar.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '৳ ${bazar.totalTaka.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
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
                        bazar.addedByName,
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
                        DateFormat('dd MMM yyyy').format(bazar.bazarDate),
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
