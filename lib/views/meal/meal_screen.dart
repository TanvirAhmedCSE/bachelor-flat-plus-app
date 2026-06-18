import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/meal_bloc/meal_bloc.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../models/meal_model.dart';
import '../../models/expense_model.dart';
import '../../app/theme.dart';

class MealScreen extends StatelessWidget {
  const MealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MealBloc()..add(MealInitialized()),
      child: const _MealView(),
    );
  }
}

class _MealView extends StatefulWidget {
  const _MealView();

  @override
  State<_MealView> createState() => _MealViewState();
}

class _MealViewState extends State<_MealView> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  final TransformationController _transformController =
      TransformationController();

  static const _months = [
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

  static const _colorYellow = Color(0xFFFFFF00);
  static const _colorCyan = Color(0xFF00FFFF);
  static const _colorHeader = Color(0xFF404040);
  static const _colorTotalRow = Color(0xFFFF6600);
  static const _colorSummaryRed = Color(0xFFCC0000);
  static const _colorMealCost = Color(0xFF003399);

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MealBloc, MealState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            title: const Text(
              'Meals',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: state is MealReady
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
                        12,
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
                        12,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text(
                            _months[i],
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      onChanged: (v) => context.read<MealBloc>().add(
                        MealMonthChanged(month: v!, year: state.selectedYear),
                      ),
                    ),
                    const SizedBox(width: 4),
                    DropdownButton<int>(
                      value: state.selectedYear,
                      dropdownColor: AppColors.customWhite,
                      underline: const SizedBox(),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                      selectedItemBuilder: (_) => List.generate(3, (i) {
                        final y = DateTime.now().year - 1 + i;
                        return Center(
                          child: Text(
                            '$y',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        );
                      }),
                      items: List.generate(3, (i) {
                        final y = DateTime.now().year - 1 + i;
                        return DropdownMenuItem(
                          value: y,
                          child: Text(
                            '$y',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        );
                      }),
                      onChanged: (v) => context.read<MealBloc>().add(
                        MealMonthChanged(month: state.selectedMonth, year: v!),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ]
                : null,
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, MealState state) {
    if (state is MealLoading || state is MealInitial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is MealFailure) {
      return Center(child: Text(state.message));
    }
    if (state is! MealReady) return const SizedBox();

    return StreamBuilder<List<MealModel>>(
      stream: FirestoreService.getMeals(
        state.currentUser.flatId,
        state.selectedYear,
        state.selectedMonth,
      ),
      builder: (ctx, mealSnap) {
        return StreamBuilder<List<ExpenseModel>>(
          stream: FirestoreService.getExpenses(state.currentUser.flatId),
          builder: (ctx, expSnap) {
            if (!mealSnap.hasData || state.members.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final meals = mealSnap.data ?? [];
            final allExpenses = expSnap.data ?? [];

            final groceryExpenses = allExpenses
                .where(
                  (e) =>
                      e.category == 'grocery' &&
                      e.date.month == state.selectedMonth &&
                      e.date.year == state.selectedYear,
                )
                .toList();

            final Map<String, Map<int, int>> mealMap = {};
            for (final m in meals) {
              mealMap[m.userId] ??= {};
              mealMap[m.userId]![m.day] = m.count;
            }

            final Map<String, List<_BazarEntry>> bazarMap = {};
            for (final e in groceryExpenses) {
              bazarMap[e.addedBy] ??= [];
              bazarMap[e.addedBy]!.add(
                _BazarEntry(date: e.date, amount: e.amount),
              );
            }

            final days = _daysInMonth(state.selectedYear, state.selectedMonth);

            return _buildZoomableContent(
              context: context,
              state: state,
              mealMap: mealMap,
              bazarMap: bazarMap,
              days: days,
              groceryExpenses: groceryExpenses,
            );
          },
        );
      },
    );
  }

  Widget _buildZoomableContent({
    required BuildContext context,
    required MealReady state,
    required Map<String, Map<int, int>> mealMap,
    required Map<String, List<_BazarEntry>> bazarMap,
    required int days,
    required List<ExpenseModel> groceryExpenses,
  }) {
    return GestureDetector(
      onScaleStart: (_) => _previousScale = _scale,
      onScaleUpdate: (details) {
        setState(() {
          _scale = (_previousScale * details.scale).clamp(0.5, 3.0);
          _transformController.value = Matrix4.identity()..scale(_scale);
        });
      },
      child: InteractiveViewer(
        transformationController: _transformController,
        minScale: 0.4,
        maxScale: 3.0,
        constrained: false,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: _buildFullTable(
              context: context,
              state: state,
              mealMap: mealMap,
              bazarMap: bazarMap,
              days: days,
              groceryExpenses: groceryExpenses,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullTable({
    required BuildContext context,
    required MealReady state,
    required Map<String, Map<int, int>> mealMap,
    required Map<String, List<_BazarEntry>> bazarMap,
    required int days,
    required List<ExpenseModel> groceryExpenses,
  }) {
    final members = state.members;

    final Map<String, int> memberTotalMeals = {};
    for (final m in members) {
      memberTotalMeals[m.uid] = (mealMap[m.uid]?.values ?? []).fold(
        0,
        (a, b) => a + b,
      );
    }

    final Map<String, double> memberTotalBazar = {};
    for (final m in members) {
      memberTotalBazar[m.uid] = (bazarMap[m.uid] ?? []).fold(
        0.0,
        (a, b) => a + b.amount,
      );
    }

    final totalBazar = memberTotalBazar.values.fold(0.0, (a, b) => a + b);
    final totalMeals = memberTotalMeals.values.fold(0, (a, b) => a + b);
    final mealRate = totalMeals > 0 ? totalBazar / totalMeals : 0.0;

    const colWidth = 70.0;
    const dateColWidth = 55.0;

    List<Widget> buildHeaderRow() {
      return [
        _cell(
          'Date',
          width: dateColWidth,
          bg: _colorHeader,
          textColor: Colors.white,
          bold: true,
          fontSize: 13,
        ),
        ...members.map(
          (m) => _cell(
            m.name.split(' ').first,
            width: colWidth,
            bg: _colorHeader,
            textColor: Colors.white,
            bold: true,
            fontSize: 12,
          ),
        ),
        _cell(
          'Total',
          width: colWidth,
          bg: _colorHeader,
          textColor: Colors.white,
          bold: true,
          fontSize: 13,
        ),
      ];
    }

    final monthTitle =
        '${_months[state.selectedMonth - 1]}-${state.selectedYear.toString().substring(2)}';
    final totalWidth = dateColWidth + colWidth * (members.length + 1);

    List<Widget> buildDayRows() {
      final rows = <Widget>[];
      for (int d = 1; d <= days; d++) {
        final rowMeals = members.map((m) => mealMap[m.uid]?[d] ?? 0).toList();
        final rowTotal = rowMeals.fold(0, (a, b) => a + b);
        final isEven = d % 2 == 0;
        final bg = isEven ? _colorCyan : _colorYellow;

        rows.add(
          Row(
            children: [
              _cell(
                '$d',
                width: dateColWidth,
                bg: bg,
                textColor: Colors.red,
                bold: true,
              ),
              ...members.asMap().entries.map((entry) {
                final member = entry.value;
                final count = rowMeals[entry.key];
                final isMe = member.uid == state.currentUser.uid;
                return GestureDetector(
                  onTap: isMe
                      ? () => _showMealPicker(context, state, d, member, count)
                      : null,
                  child: _cell(
                    '$count',
                    width: colWidth,
                    bg: bg,
                    textColor: Colors.black,
                    bold: false,
                    border: isMe
                        ? Border(
                            top: BorderSide(color: Colors.red, width: 0.8),
                            bottom: BorderSide(color: Colors.red, width: 0.8),
                            left: BorderSide(color: Colors.red, width: 1),
                            right: BorderSide(color: Colors.red, width: 1),
                          )
                        : null,
                  ),
                );
              }),
              _cell(
                '$rowTotal',
                width: colWidth,
                bg: bg,
                textColor: Colors.black,
                bold: true,
              ),
            ],
          ),
        );
      }
      return rows;
    }

    Widget buildTotalRow() {
      final grandTotal = members
          .map((m) => memberTotalMeals[m.uid] ?? 0)
          .fold(0, (a, b) => a + b);
      return Row(
        children: [
          _cell(
            'Total',
            width: dateColWidth,
            bg: _colorTotalRow,
            textColor: Colors.white,
            bold: true,
          ),
          ...members.map(
            (m) => _cell(
              '${memberTotalMeals[m.uid] ?? 0}',
              width: colWidth,
              bg: _colorTotalRow,
              textColor: Colors.white,
              bold: true,
            ),
          ),
          _cell(
            '$grandTotal',
            width: colWidth,
            bg: _colorTotalRow,
            textColor: Colors.white,
            bold: true,
          ),
        ],
      );
    }

    Widget buildBazarSection() {
      const bazarDateW = 90.0;
      const bazarAmtW = 80.0;
      const groupGap = 16.0;

      final groups = <List<UserModel>>[];
      for (int i = 0; i < members.length; i += 2) {
        groups.add(
          members.sublist(i, i + 2 > members.length ? members.length : i + 2),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groups.map((group) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: group.map((member) {
                final entries = bazarMap[member.uid] ?? [];
                entries.sort((a, b) => a.date.compareTo(b.date));
                return Padding(
                  padding: const EdgeInsets.only(right: groupGap),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _cell(
                            'Contribution',
                            width: bazarDateW,
                            bg: _colorHeader,
                            textColor: Colors.white,
                            bold: true,
                            fontSize: 11,
                          ),
                          _cell(
                            member.name.split(' ').first,
                            width: bazarAmtW,
                            bg: _colorHeader,
                            textColor: Colors.white,
                            bold: true,
                            fontSize: 11,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _cell(
                            'Date',
                            width: bazarDateW,
                            bg: const Color(0xFF808080),
                            textColor: Colors.white,
                            bold: true,
                            fontSize: 10,
                          ),
                          _cell(
                            'Amount',
                            width: bazarAmtW,
                            bg: const Color(0xFF808080),
                            textColor: Colors.white,
                            bold: true,
                            fontSize: 10,
                          ),
                        ],
                      ),
                      ...List.generate(entries.length < 5 ? 5 : entries.length, (
                        i,
                      ) {
                        final bg = i % 2 == 0 ? _colorYellow : _colorCyan;
                        if (i < entries.length) {
                          final e = entries[i];
                          return Row(
                            children: [
                              _cell(
                                '${e.date.day}/${e.date.month}/${e.date.year}',
                                width: bazarDateW,
                                bg: bg,
                                textColor: Colors.black,
                                fontSize: 10,
                              ),
                              _cell(
                                e.amount.toStringAsFixed(0),
                                width: bazarAmtW,
                                bg: bg,
                                textColor: Colors.black,
                                fontSize: 10,
                              ),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            _cell('', width: bazarDateW, bg: bg),
                            _cell('', width: bazarAmtW, bg: bg),
                          ],
                        );
                      }),
                      Row(
                        children: [
                          _cell(
                            'Total',
                            width: bazarDateW,
                            bg: const Color(0xFFD0D0D0),
                            textColor: Colors.black,
                            bold: true,
                            fontSize: 10,
                          ),
                          _cell(
                            (memberTotalBazar[member.uid] ?? 0).toStringAsFixed(
                              0,
                            ),
                            width: bazarAmtW,
                            bg: const Color(0xFFD0D0D0),
                            textColor: Colors.black,
                            bold: true,
                            fontSize: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      );
    }

    Widget buildSummaryBox() {
      return Container(
        decoration: BoxDecoration(
          color: _colorSummaryRed,
          border: Border.all(color: Colors.black, width: 1),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summaryLine('Total Bazar =', totalBazar.toStringAsFixed(0)),
            _summaryLine('Total Meal =', '$totalMeals'),
            _summaryLine('Meal Rate =', mealRate.toStringAsFixed(0)),
          ],
        ),
      );
    }

    Widget buildMealCostTable() {
      const nameW = 90.0;
      const numW = 80.0;

      Widget headerCell(String text) => _cell(
        text,
        width: numW,
        bg: _colorMealCost,
        textColor: Colors.white,
        bold: true,
        fontSize: 10,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: _colorMealCost,
            padding: const EdgeInsets.symmetric(vertical: 6),
            width: nameW + numW * 5,
            child: const Center(
              child: Text(
                'Meal Cost',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          Row(
            children: [
              _cell(
                'Name',
                width: nameW,
                bg: _colorMealCost,
                textColor: Colors.white,
                bold: true,
                fontSize: 10,
              ),
              headerCell('Total Bazar'),
              headerCell('Total Meal'),
              headerCell('Meal Rate'),
              headerCell('Meal Cost'),
              headerCell('Balance'),
            ],
          ),
          ...members.asMap().entries.map((entry) {
            final i = entry.key;
            final m = entry.value;
            final tBazar = memberTotalBazar[m.uid] ?? 0;
            final tMeal = memberTotalMeals[m.uid] ?? 0;
            final mealCost = tMeal * mealRate;
            final balance = tBazar - mealCost;
            final bg = i % 2 == 0 ? _colorYellow : _colorCyan;

            return Row(
              children: [
                _cell(
                  m.name.split(' ').first,
                  width: nameW,
                  bg: bg,
                  textColor: Colors.black,
                  bold: true,
                  fontSize: 11,
                ),
                _cell(
                  tBazar.toStringAsFixed(0),
                  width: numW,
                  bg: bg,
                  textColor: Colors.black,
                  fontSize: 11,
                ),
                _cell(
                  '$tMeal',
                  width: numW,
                  bg: bg,
                  textColor: Colors.black,
                  fontSize: 11,
                ),
                _cell(
                  mealRate.toStringAsFixed(0),
                  width: numW,
                  bg: bg,
                  textColor: Colors.black,
                  fontSize: 11,
                ),
                _cell(
                  mealCost.toStringAsFixed(0),
                  width: numW,
                  bg: bg,
                  textColor: Colors.black,
                  fontSize: 11,
                ),
                _cell(
                  balance.toStringAsFixed(0),
                  width: numW,
                  bg: bg,
                  textColor: balance >= 0 ? Colors.black : Colors.red,
                  bold: balance < 0,
                  fontSize: 11,
                ),
              ],
            );
          }),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: totalWidth,
          color: _colorHeader,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Center(
            child: Text(
              monthTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        Row(children: buildHeaderRow()),
        ...buildDayRows(),
        buildTotalRow(),
        const SizedBox(height: 24),
        buildBazarSection(),
        const SizedBox(height: 8),
        buildSummaryBox(),
        const SizedBox(height: 16),
        buildMealCostTable(),
        const SizedBox(height: 55),
      ],
    );
  }

  Widget _cell(
    String text, {
    required double width,
    Color bg = Colors.white,
    Color textColor = Colors.black,
    bool bold = false,
    double fontSize = 12,
    BoxBorder? border,
  }) {
    return Container(
      width: width,
      height: 26,
      decoration: BoxDecoration(
        color: bg,
        border: border ?? Border.all(color: Colors.black38, width: 0.5),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: textColor,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget _summaryLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showMealPicker(
    BuildContext context,
    MealReady state,
    int day,
    UserModel member,
    int current,
  ) async {
    int tempValue = current;
    final FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: current);

    final picked = await showDialog<int>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
                  Icons.restaurant_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Day $day · ${member.name.split(' ').first}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          content: SizedBox(
            height: 180,
            child: ListWheelScrollView.useDelegate(
              controller: scrollController,
              itemExtent: 48,
              perspective: 0.003,
              diameterRatio: 1.8,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) =>
                  setDialogState(() => tempValue = index),
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: 21,
                builder: (context, index) {
                  final isSelected = index == tempValue;
                  return Center(
                    child: Text(
                      index == 0 ? '0  (Skip)' : '$index',
                      style: TextStyle(
                        fontSize: isSelected ? 28 : 18,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textHint,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            SizedBox(width: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(context, tempValue),
              child: const Text('Save'),
            ),
            SizedBox(width: 4),
          ],
        ),
      ),
    );

    scrollController.dispose();

    if (picked == null) return;
    if (!context.mounted) return;

    context.read<MealBloc>().add(MealCountUpdated(day: day, count: picked));
  }
}

class _BazarEntry {
  final DateTime date;
  final double amount;
  const _BazarEntry({required this.date, required this.amount});
}
