import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/notice_model.dart';
import '../../app/theme.dart';

class NoticeDetailsScreen extends StatelessWidget {
  final NoticeModel notice;

  const NoticeDetailsScreen({super.key, required this.notice});

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

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(notice.category);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Notice Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
                boxShadow: AppColors.otherShadow,
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
                    child: Icon(
                      _categoryIcon(notice.category),
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
                          notice.title,
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
                            notice.category,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
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

            //  Meta info
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
                    'Posted by',
                    notice.addedByName,
                  ),
                  const SizedBox(height: 10),
                  _metaRow(
                    Icons.calendar_today_rounded,
                    'Date',
                    DateFormat('dd MMM yyyy • hh:mm a').format(notice.addedAt),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            //  Description
            if (notice.description.isNotEmpty) ...[
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
                  notice.description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            //  Images
            if (notice.imageUrls.isNotEmpty) ...[
              Text(
                'IMAGES (${notice.imageUrls.length})',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              ...notice.imageUrls.map((url) {
                return Padding(
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
                );
              }),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
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
