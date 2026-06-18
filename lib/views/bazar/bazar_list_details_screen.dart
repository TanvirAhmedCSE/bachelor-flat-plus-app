import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/bazar_list_model.dart';
import '../../app/theme.dart';
import 'create_and_edit_bazar_list_screen.dart';

class BazarListDetailsScreen extends StatefulWidget {
  final BazarListModel bazar;
  final String flatId;

  const BazarListDetailsScreen({
    super.key,
    required this.bazar,
    required this.flatId,
  });

  @override
  State<BazarListDetailsScreen> createState() => _BazarListDetailsScreenState();
}

class _BazarListDetailsScreenState extends State<BazarListDetailsScreen> {
  late BazarListModel _bazar;

  @override
  void initState() {
    super.initState();
    _bazar = widget.bazar;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            '/bazar-list',
            (route) => route.settings.name == '/home' || route.isFirst,
          ),
        ),
        title: const Text(
          'Bazar Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateAndEditBazarListScreen(
                    flatId: widget.flatId,
                    existing: _bazar,
                  ),
                ),
              );
              if (result == true && context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/bazar-list',
                  (route) => route.settings.name == '/home' || route.isFirst,
                );
              }
            },
            icon: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
            label: const Text(
              'Edit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  Header card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.secondaryShadow,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.shopping_basket_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _bazar.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '৳ ${_bazar.totalTaka.toStringAsFixed(0)} total',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            //  Meta
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.customWhite,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppColors.otherShadow,
              ),
              child: Column(
                children: [
                  _metaRow(
                    Icons.person_outline_rounded,
                    'Added by',
                    _bazar.addedByName,
                  ),
                  const SizedBox(height: 10),
                  _metaRow(
                    Icons.calendar_today_rounded,
                    'Bazar Date',
                    DateFormat('dd MMM yyyy').format(_bazar.bazarDate),
                  ),
                  const SizedBox(height: 10),
                  _metaRow(
                    Icons.access_time_rounded,
                    'Added at',
                    DateFormat('dd MMM yyyy • hh:mm a').format(_bazar.addedAt),
                  ),
                ],
              ),
            ),

            //  Description
            if (_bazar.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'DESCRIPTION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.customWhite,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppColors.otherShadow,
                ),
                child: Text(
                  _bazar.description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],

            //  Bazar Table
            if (_bazar.rows.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'BAZAR ITEMS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.customWhite,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppColors.otherShadow,
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildTable(),
              ),
            ],

            //  Images
            if (_bazar.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'IMAGES (${_bazar.imageUrls.length})',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              ..._bazar.imageUrls.map(
                (url) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => _openFullscreen(context, url),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: CachedNetworkImage(
                        imageUrl: url,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          height: 200,
                          color: AppColors.divider,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          height: 120,
                          color: AppColors.accentFaint,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    final cols = _bazar.columns;
    final rows = _bazar.rows;
    return Table(
      border: TableBorder(
        horizontalInside: BorderSide(color: AppColors.divider),
        verticalInside: BorderSide(color: AppColors.divider),
      ),
      columnWidths: {
        0: const FlexColumnWidth(2),
        for (int i = 1; i < cols.length; i++) i: const FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(color: AppColors.primary),
          children: cols
              .map(
                (c) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Text(
                    c['name'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        ...rows.asMap().entries.map((entry) {
          final isEven = entry.key % 2 == 0;
          return TableRow(
            decoration: BoxDecoration(
              color: isEven ? AppColors.customWhite : AppColors.surface,
            ),
            children: List.generate(
              cols.length,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Text(
                  entry.value['col$i']?.toString() ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: i == 0 ? TextAlign.left : TextAlign.center,
                ),
              ),
            ),
          );
        }),
        if (cols.any((c) => (c['name'] as String).toLowerCase() == 'taka'))
          TableRow(
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
            ),
            children: List.generate(cols.length, (i) {
              final isTaka =
                  (cols[i]['name'] as String).toLowerCase() == 'taka';
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: isTaka
                    ? Text(
                        '৳ ${_bazar.totalTaka.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.success,
                        ),
                        textAlign: TextAlign.center,
                      )
                    : i == 0
                    ? const Text(
                        'Total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.success,
                        ),
                      )
                    : const SizedBox.shrink(),
              );
            }),
          ),
      ],
    );
  }

  Widget _metaRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  void _openFullscreen(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}
