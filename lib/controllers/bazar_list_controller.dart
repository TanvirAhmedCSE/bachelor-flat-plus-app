import 'dart:io';
import 'package:uuid/uuid.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../services/cloudinary_service.dart';
import '../models/bazar_list_model.dart';
import '../models/activity_log_model.dart';

class BazarListController {
  Future<String?> addBazarList({
    required String flatId,
    required String title,
    required String description,
    required DateTime bazarDate,
    required String addedByName,
    required List<Map<String, dynamic>> columns,
    required List<Map<String, dynamic>> rows,
    required List<File> imageFiles,
    required double totalTaka,
  }) async {
    final uid = AuthService.currentUser!.uid;

    final List<String> imageUrls = [];
    for (final file in imageFiles) {
      final url = await CloudinaryService.uploadImage(file);
      if (url != null) imageUrls.add(url);
    }

    final id = const Uuid().v4();
    final bazar = BazarListModel(
      id: id,
      title: title,
      description: description,
      bazarDate: bazarDate,
      addedBy: uid,
      addedByName: addedByName,
      addedAt: DateTime.now(),
      columns: columns,
      rows: rows,
      imageUrls: imageUrls,
      totalTaka: totalTaka,
    );

    await FirestoreService.addBazarList(flatId, bazar);

    await FirestoreService.logActivity(
      flatId,
      ActivityLogModel(
        id: const Uuid().v4(),
        type: 'bazar_add',
        by: uid,
        byName: addedByName,
        message: '$addedByName added a bazar list: "$title"',
        timestamp: DateTime.now(),
        relatedId: id,
      ),
    );

    return null;
  }

  Future<String?> updateBazarList({
    required String flatId,
    required BazarListModel existing,
    required String title,
    required String description,
    required DateTime bazarDate,
    required String updatedByName,
    required List<Map<String, dynamic>> columns,
    required List<Map<String, dynamic>> rows,
    required List<String> existingImageUrls,
    required List<File> newImageFiles,
    required double totalTaka,
  }) async {
    final uid = AuthService.currentUser!.uid;

    final List<String> imageUrls = List.from(existingImageUrls);
    for (final file in newImageFiles) {
      final url = await CloudinaryService.uploadImage(file);
      if (url != null) imageUrls.add(url);
    }

    final updated = BazarListModel(
      id: existing.id,
      title: title,
      description: description,
      bazarDate: bazarDate,
      addedBy: existing.addedBy,
      addedByName: existing.addedByName,
      addedAt: existing.addedAt,
      columns: columns,
      rows: rows,
      imageUrls: imageUrls,
      totalTaka: totalTaka,
    );

    await FirestoreService.updateBazarList(flatId, updated);

    await FirestoreService.logActivity(
      flatId,
      ActivityLogModel(
        id: const Uuid().v4(),
        type: 'bazar_update',
        by: uid,
        byName: updatedByName,
        message: '$updatedByName updated bazar list: "$title"',
        timestamp: DateTime.now(),
        relatedId: existing.id,
      ),
    );

    return null;
  }
}
