import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../services/onesignal_service.dart';
import '../services/firestore_service.dart';

class AuthController {
  final BuildContext context;
  bool isLoading = false;

  AuthController(this.context);

  Future<void> login(
    String email,
    String password,
    VoidCallback onSuccess,
  ) async {
    final error = await AuthService.login(email: email, password: password);
    if (error != null) {
      _showSnack(error);
      return;
    }
    final user = AuthService.currentUser;
    if (user == null) return;
    if (!user.emailVerified) {
      Navigator.pushReplacementNamed(context, '/verify-email');
      return;
    }

    await OneSignalService.loginUser(user.uid);
    final playerId = await OneSignalService.getPlayerId();
    if (playerId != null) {
      await FirestoreService.saveOneSignalPlayerId(user.uid, playerId);
    }

    onSuccess();
  }

  Future<void> logout() async {
    await AuthService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<UserModel?> getCurrentUser() => AuthService.getCurrentUserModel();

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
