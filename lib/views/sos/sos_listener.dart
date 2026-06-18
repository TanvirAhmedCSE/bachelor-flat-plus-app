import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibration/vibration.dart';
import '../../bloc/sos_bloc/sos_bloc.dart';
import '../../models/sos_alert_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import 'sos_location_screen.dart';

class SosListener extends StatelessWidget {
  final UserModel currentUser;
  final Widget child;

  const SosListener({
    super.key,
    required this.currentUser,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SosBloc()
        ..add(
          SosListenerStarted(
            flatId: currentUser.flatId,
            currentUserUid: currentUser.uid,
          ),
        ),
      child: _SosListenerView(currentUser: currentUser, child: child),
    );
  }
}

class _SosListenerView extends StatefulWidget {
  final UserModel currentUser;
  final Widget child;

  const _SosListenerView({required this.currentUser, required this.child});

  @override
  State<_SosListenerView> createState() => _SosListenerViewState();
}

class _SosListenerViewState extends State<_SosListenerView> {
  final _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startAlarm() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/sos_alarm.mp3'));
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (_) {}
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [0, 500, 300, 500, 300, 500], repeat: 0);
    }
  }

  Future<void> _stopAlarm() async {
    await _audioPlayer.stop();
    Vibration.cancel();
  }

  void _showSosPopup(SosAlertModel alert) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SosReceiverDialog(
        alert: alert,
        onViewLocation: () {
          _stopAlarm();
          context.read<SosBloc>().add(SosAlertDismissed(alert.id));
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SosLocationScreen(alert: alert)),
          );
        },
        onDismiss: () {
          _stopAlarm();
          context.read<SosBloc>().add(SosAlertDismissed(alert.id));
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SosBloc, SosState>(
      listener: (context, state) {
        if (state is SosAlertReceived) {
          _startAlarm();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showSosPopup(state.alert);
          });
        } else if (state is SosAlertCancelled) {
          _stopAlarm();
        }
      },
      child: widget.child,
    );
  }
}

//  SOS Receiver Dialog
class _SosReceiverDialog extends StatelessWidget {
  final SosAlertModel alert;
  final VoidCallback onViewLocation;
  final VoidCallback onDismiss;

  const _SosReceiverDialog({
    required this.alert,
    required this.onViewLocation,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SosAlertModel>>(
      stream: FirestoreService.getActiveSosAlerts(alert.flatId),
      builder: (context, snap) {
        SosAlertModel current = alert;
        if (snap.hasData) {
          final found = snap.data!.where((a) => a.id == alert.id);
          if (found.isNotEmpty) current = found.first;
        }

        if (!current.isActive) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context, rootNavigator: true).pop();
          });
        }

        final mapsLink =
            'https://maps.google.com/?q=${current.latitude},${current.longitude}';

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.sos, color: Colors.white, size: 52),
                      const SizedBox(height: 8),
                      const Text(
                        '🚨 SOS ALERT!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${current.victimName} needs help!',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.red.shade400,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Live Location',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      const Text(
                                        'Updating',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${current.latitude.toStringAsFixed(5)}, ${current.longitude.toStringAsFixed(5)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    mapsLink,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue.shade600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onViewLocation,
                          icon: const Icon(Icons.map),
                          label: const Text('View & Track Location'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: onDismiss,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Dismiss Alert',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
