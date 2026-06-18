import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../services/cloudinary_service.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/message_model.dart';

class ChatController {
  final BuildContext context;
  ChatController(this.context);

  Future<void> sendTextMessage({
    required String flatId,
    required String chatId,
    required String text,
    required String senderName,
  }) async {
    if (text.trim().isEmpty) return;
    final uid = AuthService.currentUser!.uid;
    final msg = MessageModel(
      id: const Uuid().v4(),
      senderId: uid,
      senderName: senderName,
      text: text.trim(),
      type: 'text',
      timestamp: DateTime.now(),
    );
    await FirestoreService.sendMessage(flatId, chatId, msg);
  }

  Future<void> pickAndSendImage({
    required String flatId,
    required String chatId,
    required String senderName,
    required VoidCallback onUploading,
    required VoidCallback onDone,
  }) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked == null) return;

    onUploading();

    final url = await CloudinaryService.uploadImage(File(picked.path));
    if (url == null) {
      onDone();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Image upload failed')));
      }
      return;
    }

    final uid = AuthService.currentUser!.uid;
    final msg = MessageModel(
      id: const Uuid().v4(),
      senderId: uid,
      senderName: senderName,
      imageUrl: url,
      type: 'image',
      timestamp: DateTime.now(),
    );
    await FirestoreService.sendMessage(flatId, chatId, msg);
    onDone();
  }
}
