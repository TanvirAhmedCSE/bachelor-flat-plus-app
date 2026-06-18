import 'dart:io';
import 'package:uuid/uuid.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../services/cloudinary_service.dart';
import '../models/notice_model.dart';
import '../models/activity_log_model.dart';

class NoticeController {
  Future<String?> addNotice({
    required String flatId,
    required String title,
    required String description,
    required String category,
    required String addedByName,
    required List<File> imageFiles,
  }) async {
    final uid = AuthService.currentUser!.uid;

    // Upload images to Cloudinary
    final List<String> imageUrls = [];
    for (final file in imageFiles) {
      final url = await CloudinaryService.uploadImage(file);
      if (url != null) imageUrls.add(url);
    }

    final id = const Uuid().v4();
    final notice = NoticeModel(
      id: id,
      title: title,
      description: description,
      category: category,
      addedBy: uid,
      addedByName: addedByName,
      addedAt: DateTime.now(),
      imageUrls: imageUrls,
    );

    await FirestoreService.addNotice(flatId, notice);

    final log = ActivityLogModel(
      id: const Uuid().v4(),
      type: 'notice_add',
      by: uid,
      byName: addedByName,
      message: '$addedByName added a notice: "$title" [$category]',
      timestamp: DateTime.now(),
      relatedId: id,
    );
    await FirestoreService.logActivity(flatId, log);

    return null;
  }
}
