import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalService {
  // Replace with your actual OneSignal App ID
  static const String _appId = 'XXXXXXXXXXXXXXXXXXXXXXX';

  static Future<void> init() async {
    OneSignal.initialize(_appId);
    await OneSignal.Notifications.requestPermission(true);
  }

  static Future<void> loginUser(String uid) async {
    await OneSignal.login(uid);
  }

  static Future<void> logoutUser() async {
    await OneSignal.logout();
  }

  static Future<void> sendSosNotification({
    required List<String> targetUids,
    required String victimName,
    required String sosAlertId,
    required double latitude,
    required double longitude,
  }) async {}

  static Future<String?> getPlayerId() async {
    return OneSignal.User.pushSubscription.id;
  }
}
