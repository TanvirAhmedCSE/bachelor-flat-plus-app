import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:vibration/vibration.dart';
import '../models/sos_alert_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class SosController {
  // Replace with your actual OneSignal Rest API Key & App ID
  static const String _oneSignalRestApiKey =
      'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
  static const String _oneSignalAppId = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXX';

  static final AudioPlayer _audioPlayer = AudioPlayer();

  static StreamSubscription<Position>? _locationSub;

  static String? _activeSosId;
  static bool _isActive = false;

  static bool get isActive => _isActive;
  static String? get activeSosId => _activeSosId;

  static Future<void> triggerSos({
    required String flatId,
    required String victimName,
    required String victimUid,
  }) async {
    if (_isActive) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      position = Position(
        latitude: 0,
        longitude: 0,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    }

    final alertId = const Uuid().v4();
    _activeSosId = alertId;
    _isActive = true;

    final alert = SosAlertModel(
      id: alertId,
      victimUid: victimUid,
      victimName: victimName,
      flatId: flatId,
      latitude: position.latitude,
      longitude: position.longitude,
      triggeredAt: DateTime.now(),
      isActive: true,
    );
    await FirestoreService.createSosAlert(alert);

    await _startAlarm();

    final playerIds = await FirestoreService.getMembersPlayerIds(
      flatId,
      victimUid,
    );
    if (playerIds.isNotEmpty) {
      await _sendPushNotification(
        playerIds: playerIds,
        victimName: victimName,
        alertId: alertId,
        lat: position.latitude,
        lng: position.longitude,
      );
    }

    _locationSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen(
          (Position pos) async {
            if (!_isActive) {
              await _locationSub?.cancel();
              return;
            }
            try {
              await FirestoreService.updateSosLocation(
                flatId,
                alertId,
                pos.latitude,
                pos.longitude,
              );
            } catch (_) {}
          },
          onError: (_) {}, // silently ignore stream errors
          cancelOnError: false,
        );
  }

  static Future<void> cancelSos(String flatId) async {
    if (!_isActive || _activeSosId == null) return;
    _isActive = false;
    await _locationSub?.cancel();
    _locationSub = null;
    await FirestoreService.cancelSosAlert(flatId, _activeSosId!);
    _activeSosId = null;
    await _stopAlarm();
  }

  static Future<void> _startAlarm() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/sos_alarm.mp3'));
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (_) {}

    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [0, 500, 300, 500, 300, 500], repeat: 0);
    }
  }

  static Future<void> _stopAlarm() async {
    await _audioPlayer.stop();
    Vibration.cancel();
  }

  static Future<void> _sendPushNotification({
    required List<String> playerIds,
    required String victimName,
    required String alertId,
    required double lat,
    required double lng,
  }) async {
    try {
      final mapsLink = 'https://maps.google.com/?q=$lat,$lng';
      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_oneSignalRestApiKey',
        },
        body: jsonEncode({
          'app_id': _oneSignalAppId,
          'include_player_ids': playerIds,
          'headings': {'en': '🚨 SOS Alert!'},
          'contents': {'en': '$victimName needs help! Tap to see location.'},
          'data': {
            'type': 'sos',
            'alertId': alertId,
            'flatId': AuthService.currentUser?.uid ?? '',
            'lat': lat,
            'lng': lng,
            'mapsLink': mapsLink,
          },
          'priority': 10,
          'android_visibility': 1,
        }),
      );
      print('OneSignal response: ${response.statusCode}');
      print('OneSignal body: ${response.body}');
    } catch (e) {
      print('OneSignal error: $e');
    }
  }

  static Future<void> stopLocalAlarm() async {
    await _stopAlarm();
  }
}
