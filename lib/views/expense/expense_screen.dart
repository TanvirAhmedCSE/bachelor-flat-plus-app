import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/expense_bloc/expense_bloc.dart';
import '../../services/firestore_service.dart';
import '../../models/expense_model.dart';
import '../../app/theme.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExpenseBloc()..add(ExpenseInitialized()),
      child: const _ExpenseView(),
    );
  }
}

class _ExpenseView extends StatelessWidget {
  const _ExpenseView();

  static const _categories = [
    'All',
    'rent',
    'utility',
    'grocery',
    'event',
    'festival bonus',
    'other',
  ];

  static const _categoryLabels = {
    'All': 'All',
    'rent': 'Rent',
    'utility': 'Utility',
    'grocery': 'Grocery',
    'event': 'Event',
    'festival bonus': 'Festival Bonus',
    'other': 'Other',
  };

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

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'rent':
        return const Color(0xFF5A8FA8);
      case 'utility':
        return const Color(0xFFF2A65A);
      case 'grocery':
        return const Color(0xFF4CAF82);
      case 'event':
        return const Color(0xFF9B72CF);
      case 'festival bonus':
        return const Color(0xFFE07A5F);
      default:
        return const Color(0xFF6E6B65);
    }
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'rent':
        return Icons.home_rounded;
      case 'utility':
        return Icons.bolt_rounded;
      case 'grocery':
        return Icons.restaurant_rounded;
      case 'event':
        return Icons.event_rounded;
      case 'festival bonus':
        return Icons.card_giftcard_rounded;
      default:
        return Icons.receipt_rounded;
    }
  }

  List<ExpenseModel> _filtered(List<ExpenseModel> all, ExpenseReady state) {
    return all.where((e) {
      final catOk =
          state.selectedCategory == 'All' ||
          e.category == state.selectedCategory;
      final memberOk =
          state.selectedMember == 'All' || e.addedBy == state.selectedMember;
      final monthOk =
          state.selectedMonth == 0 || e.date.month == state.selectedMonth;
      return catOk && memberOk && monthOk;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            title: const Text(
              'Expenses',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: state is ExpenseReady
                ? [
                    DropdownButton<int>(
                      value: state.selectedMonth,
                      dropdownColor: AppColors.customWhite,
                      underline: const SizedBox(),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
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
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      onChanged: (v) => context.read<ExpenseBloc>().add(
                        ExpenseMonthChanged(v!),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ]
                : null,
          ),
          body: _buildBody(context, state),
          floatingActionButton: state is ExpenseReady
              ? FloatingActionButton(
                  onPressed: () => _showAddExpenseDialog(context, state),
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ExpenseState state) {
    if (state is ExpenseLoading || state is ExpenseInitial) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (state is ExpenseFailure) return Center(child: Text(state.message));
    if (state is! ExpenseReady) return const SizedBox();

    return StreamBuilder<List<ExpenseModel>>(
      stream: FirestoreService.getExpenses(state.currentUser.flatId),
      builder: (context, snap) {
        if (!snap.hasData)
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        final filtered = _filtered(snap.data!, state);
        final total = filtered.fold(0.0, (s, e) => s + e.amount);

        return Column(
          children: [
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
                  final isSelected = state.selectedCategory == cat;
                  final color = cat == 'All'
                      ? AppColors.primary
                      : _categoryColor(cat);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => context.read<ExpenseBloc>().add(
                        ExpenseCategoryChanged(cat),
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
                              _categoryLabels[cat]!,
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

            //  Member chips
            if (state.members.isNotEmpty)
              SizedBox(
                height: 46,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  itemCount: state.members.length + 1,
                  itemBuilder: (_, i) {
                    if (i == 0) {
                      final isSelected = state.selectedMember == 'All';
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => context.read<ExpenseBloc>().add(
                            ExpenseMemberChanged('All'),
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
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
                              'All',
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
                    }
                    final member = state.members[i - 1];
                    final isSelected = state.selectedMember == member.uid;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => context.read<ExpenseBloc>().add(
                          ExpenseMemberChanged(member.uid),
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 9,
                                backgroundColor: isSelected
                                    ? Colors.white24
                                    : AppColors.primary,
                                child: Text(
                                  member.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                member.name.split(' ').first,
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

            //  Total card
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppColors.secondaryShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        state.selectedCategory == 'All' &&
                                state.selectedMember == 'All' &&
                                state.selectedMonth == 0
                            ? 'Total Expenses'
                            : 'Filtered Total',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '৳${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),

            //  List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            size: 56,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No expenses found',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 130),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final e = filtered[i];
                        final color = _categoryColor(e.category);
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.customWhite,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: AppColors.secondaryShadow,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            leading: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _categoryIcon(e.category),
                                color: color,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              e.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),

                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${e.addedByName} • ${DateFormat('dd MMM').format(e.date)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _categoryLabels[e.category] ?? e.category,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Text(
                              '৳${e.amount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddExpenseDialog(
    BuildContext context,
    ExpenseReady state,
  ) async {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String category = 'other';

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDs) => AlertDialog(
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
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Add Expense',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                decoration: const InputDecoration(labelText: 'Amount (৳)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(value: 'rent', child: Text('Rent')),
                  DropdownMenuItem(value: 'utility', child: Text('Utility')),
                  DropdownMenuItem(value: 'grocery', child: Text('Grocery')),
                  DropdownMenuItem(value: 'event', child: Text('Event')),
                  DropdownMenuItem(
                    value: 'festival bonus',
                    child: Text('Festival Bonus'),
                  ),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (v) => setDs(() => category = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountCtrl.text);
                if (titleCtrl.text.isEmpty || amount == null) return;
                Navigator.pop(ctx);
                context.read<ExpenseBloc>().add(
                  ExpenseAdded(
                    title: titleCtrl.text.trim(),
                    amount: amount,
                    category: category,
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
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
