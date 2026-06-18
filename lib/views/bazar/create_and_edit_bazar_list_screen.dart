import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../controllers/bazar_list_controller.dart';
import '../../models/bazar_list_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../app/theme.dart';

class CreateAndEditBazarListScreen extends StatefulWidget {
  final String flatId;
  final BazarListModel? existing;

  const CreateAndEditBazarListScreen({
    super.key,
    required this.flatId,
    this.existing,
  });

  @override
  State<CreateAndEditBazarListScreen> createState() =>
      _CreateAndEditBazarListScreenState();
}

class _CreateAndEditBazarListScreenState
    extends State<CreateAndEditBazarListScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _bazarDate;
  bool _loading = false;
  UserModel? _currentUser;

  final List<String> _columnNames = ['Product', 'Weight', 'Count', 'Taka'];
  final List<List<TextEditingController>> _rows = [];
  final List<String> _existingImageUrls = [];
  final List<File> _newImageFiles = [];

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    AuthService.getCurrentUserModel().then((u) {
      if (mounted) setState(() => _currentUser = u);
    });

    if (_isEdit) {
      final e = widget.existing!;
      _titleCtrl.text = e.title;
      _descCtrl.text = e.description;
      _bazarDate = e.bazarDate;
      _existingImageUrls.addAll(e.imageUrls);
      _columnNames.clear();
      _columnNames.addAll(e.columns.map((c) => c['name'] as String));
      for (final row in e.rows) {
        final ctrls = List.generate(
          _columnNames.length,
          (i) => TextEditingController(text: row['col$i']?.toString() ?? ''),
        );
        _rows.add(ctrls);
      }
    } else {
      for (int i = 0; i < 3; i++) _addRow();
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    for (final row in _rows) for (final c in row) c.dispose();
    super.dispose();
  }

  void _addRow() {
    setState(
      () => _rows.add(
        List.generate(_columnNames.length, (_) => TextEditingController()),
      ),
    );
  }

  void _addColumn() async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
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
                Icons.add_box_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Column Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Brand, Note...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
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
    );
    if (name == null || name.isEmpty) return;
    setState(() {
      _columnNames.add(name);
      for (final row in _rows) row.add(TextEditingController());
    });
  }

  void _removeRow(int index) {
    setState(() {
      for (final c in _rows[index]) c.dispose();
      _rows.removeAt(index);
    });
  }

  double _calcTotal() {
    final takaColIdx = _columnNames.indexWhere(
      (n) => n.toLowerCase() == 'taka',
    );
    if (takaColIdx < 0) return 0;
    double total = 0;
    for (final row in _rows) {
      if (takaColIdx < row.length)
        total += double.tryParse(row[takaColIdx].text) ?? 0;
    }
    return total;
  }

  bool _hasAtLeastOneFilledRow() {
    for (final row in _rows)
      if (row.any((c) => c.text.trim().isNotEmpty)) return true;
    return false;
  }

  bool _validate() {
    if (_titleCtrl.text.trim().isEmpty) {
      _showSnack('Title দাও');
      return false;
    }
    if (_bazarDate == null) {
      _showSnack('Bazar date বেছে নাও');
      return false;
    }
    if (!_hasAtLeastOneFilledRow() &&
        _existingImageUrls.isEmpty &&
        _newImageFiles.isEmpty) {
      _showSnack('অন্তত একটা product row fill করো অথবা image add করো');
      return false;
    }
    return true;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _bazarDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _bazarDate = picked);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked != null) setState(() => _newImageFiles.add(File(picked.path)));
  }

  Future<void> _save() async {
    if (!_validate()) return;
    setState(() => _loading = true);

    final columns = _columnNames
        .asMap()
        .entries
        .map((e) => {'name': e.value, 'index': e.key})
        .toList();
    final countColIdx = _columnNames.indexWhere(
      (n) => n.toLowerCase() == 'count',
    );
    final takaColIdx = _columnNames.indexWhere(
      (n) => n.toLowerCase() == 'taka',
    );
    final weightColIdx = _columnNames.indexWhere(
      (n) => n.toLowerCase() == 'weight',
    );

    final rows = _rows
        .map((row) {
          final Map<String, dynamic> r = {};
          for (int i = 0; i < row.length; i++) {
            final val = row[i].text.trim();
            final isZeroDefault =
                i == countColIdx || i == takaColIdx || i == weightColIdx;
            r['col$i'] = val.isEmpty && isZeroDefault ? '0' : val;
          }
          return r;
        })
        .where((r) => r.values.any((v) => (v as String).isNotEmpty))
        .toList();

    final ctrl = BazarListController();
    String? error;

    if (_isEdit) {
      error = await ctrl.updateBazarList(
        flatId: widget.flatId,
        existing: widget.existing!,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        bazarDate: _bazarDate!,
        updatedByName: _currentUser?.name ?? '',
        columns: columns,
        rows: rows,
        existingImageUrls: _existingImageUrls,
        newImageFiles: _newImageFiles,
        totalTaka: _calcTotal(),
      );
    } else {
      error = await ctrl.addBazarList(
        flatId: widget.flatId,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        bazarDate: _bazarDate!,
        addedByName: _currentUser?.name ?? '',
        columns: columns,
        rows: rows,
        imageFiles: _newImageFiles,
        totalTaka: _calcTotal(),
      );
    }

    if (mounted) setState(() => _loading = false);
    if (error != null) {
      _showSnack(error);
      return;
    }
    if (mounted) Navigator.pop(context, _isEdit ? true : null);
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final total = _calcTotal();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          _isEdit ? 'Edit Bazar List' : 'Create Bazar List',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  Title & Description
            const Text(
              'DETAILS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.customWhite,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppColors.secondaryShadow,
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      prefixIcon: Icon(Icons.title_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      prefixIcon: Icon(Icons.notes_rounded),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
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
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _bazarDate == null
                                ? 'Select Bazar Date *'
                                : DateFormat('dd MMM yyyy').format(_bazarDate!),
                            style: TextStyle(
                              fontSize: 14,
                              color: _bazarDate == null
                                  ? AppColors.textHint
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            //  Bazar Items Table
            Row(
              children: [
                const Text(
                  'BAZAR ITEMS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _addColumn,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_circle_outline_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Add Column',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: AppColors.customWhite,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppColors.secondaryShadow,
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildTableHeader(),
                  Divider(color: AppColors.divider, thickness: 1.5),
                  ..._rows.asMap().entries.map(
                    (entry) => _buildTableRow(entry.key, entry.value),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _addRow,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Add Row',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (_columnNames.any((n) => n.toLowerCase() == 'taka')) ...[
                    Divider(color: AppColors.divider),
                    _buildTotalRow(total),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            //  Images
            const Text(
              'IMAGES (OPTIONAL)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.customWhite,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppColors.secondaryShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_existingImageUrls.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _existingImageUrls
                          .asMap()
                          .entries
                          .map(
                            (e) => Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    e.value,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => setState(
                                      () => _existingImageUrls.removeAt(e.key),
                                    ),
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
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (_newImageFiles.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _newImageFiles
                          .asMap()
                          .entries
                          .map(
                            (e) => Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    e.value,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => setState(
                                      () => _newImageFiles.removeAt(e.key),
                                    ),
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
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 10),
                  ],
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(
                      Icons.add_photo_alternate_rounded,
                      size: 18,
                    ),
                    label: Text(
                      (_existingImageUrls.isEmpty && _newImageFiles.isEmpty)
                          ? 'Add Image'
                          : 'Add Another Image',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            //  Save Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _save,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        _isEdit
                            ? Icons.save_rounded
                            : Icons.check_circle_outline_rounded,
                      ),
                label: Text(
                  _isEdit ? 'Save Changes' : 'Done Creating',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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

  Widget _buildTableHeader() {
    return Row(
      children: [
        ..._columnNames.asMap().entries.map(
          (e) => Expanded(
            flex: e.key == 0 ? 2 : 1,
            child: Padding(
              padding: EdgeInsets.only(
                right: e.key == _columnNames.length - 1 ? 0 : 4,
              ),
              child: Text(
                e.value,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: AppColors.primary,
                ),
                textAlign: e.key == 0 ? TextAlign.left : TextAlign.center,
              ),
            ),
          ),
        ),
        const SizedBox(width: 28),
      ],
    );
  }

  Widget _buildTableRow(int rowIdx, List<TextEditingController> ctrls) {
    final takaColIdx = _columnNames.indexWhere(
      (n) => n.toLowerCase() == 'taka',
    );
    final countColIdx = _columnNames.indexWhere(
      (n) => n.toLowerCase() == 'count',
    );
    final weightColIdx = _columnNames.indexWhere(
      (n) => n.toLowerCase() == 'weight',
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ...ctrls.asMap().entries.map((e) {
            final colIdx = e.key;
            final isProduct = colIdx == 0;
            final isTaka = colIdx == takaColIdx;
            final isNumeric =
                isTaka ||
                colIdx == countColIdx ||
                (!isProduct &&
                    _columnNames[colIdx].toLowerCase().contains(
                      RegExp(r'weight|kg|gm|liter|count'),
                    ));
            return Expanded(
              flex: isProduct ? 2 : 1,
              child: Padding(
                padding: EdgeInsets.only(
                  right: colIdx == ctrls.length - 1 ? 0 : 4,
                ),
                child: TextField(
                  controller: e.value,
                  textAlign: isProduct ? TextAlign.left : TextAlign.center,
                  keyboardType: isNumeric
                      ? const TextInputType.numberWithOptions(decimal: true)
                      : TextInputType.text,
                  inputFormatters: isNumeric
                      ? [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))]
                      : null,
                  onChanged: (_) {
                    if (isTaka) setState(() {});
                  },
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    hintText:
                        (colIdx == countColIdx ||
                            isTaka ||
                            colIdx == weightColIdx)
                        ? '0'
                        : null,
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              ),
            );
          }),
          SizedBox(
            width: 28,
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 18,
              color: AppColors.error,
              onPressed: _rows.length > 1 ? () => _removeRow(rowIdx) : null,
              icon: const Icon(Icons.remove_circle_outline_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(double total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text(
            'Total: ',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              '৳ ${total.toStringAsFixed(0)}',
              style: const TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
