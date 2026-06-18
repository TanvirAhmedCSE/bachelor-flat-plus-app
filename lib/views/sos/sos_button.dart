import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/sos_controller.dart';
import '../../models/sos_alert_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../app/theme.dart';

class SosButton extends StatefulWidget {
  final UserModel currentUser;

  const SosButton({super.key, required this.currentUser});

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;
  Timer? _holdTimer;
  bool _holding = false;
  double _holdProgress = 0.0;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _holdTimer?.cancel();
    _progressTimer?.cancel();
    super.dispose();
  }

  void _onHoldStart() {
    if (SosController.isActive) return;
    _holding = true;
    _holdProgress = 0.0;
    _animCtrl.forward();
    HapticFeedback.mediumImpact();

    // 1 second hold progress
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (!_holding) {
        t.cancel();
        return;
      }
      setState(() {
        _holdProgress += 0.05;
        if (_holdProgress >= 1.0) {
          _holdProgress = 1.0;
          t.cancel();
        }
      });
    });

    _holdTimer = Timer(const Duration(seconds: 1), () async {
      if (!_holding) return;
      HapticFeedback.heavyImpact();
      await SosController.triggerSos(
        flatId: widget.currentUser.flatId,
        victimName: widget.currentUser.name,
        victimUid: widget.currentUser.uid,
      );
      if (mounted) setState(() {});
      _showSosActiveDialog();
    });
  }

  void _onHoldEnd() {
    _holding = false;
    _holdTimer?.cancel();
    _progressTimer?.cancel();
    _animCtrl.reverse();
    if (mounted) setState(() => _holdProgress = 0.0);
  }

  Future<void> _showSosActiveDialog() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SosActiveDialog(
        victimName: widget.currentUser.name,
        flatId: widget.currentUser.flatId,
        onCancel: () async {
          await SosController.cancelSos(widget.currentUser.flatId);
          if (mounted) setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActive = SosController.isActive;

    return GestureDetector(
      onTapDown: (_) => _onHoldStart(),
      onTapUp: (_) => _onHoldEnd(),
      onTapCancel: _onHoldEnd,
      onTap: isActive ? _showSosActiveDialog : null,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Card(
          margin: EdgeInsets.zero,

          color: Colors.red,

          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.divider, width: 1),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Progress ring
              if (_holdProgress > 0 && !isActive)
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: CircularProgressIndicator(
                      value: _holdProgress,
                      strokeWidth: 4,
                      backgroundColor: Colors.white70,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                ),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sos, color: Colors.white, size: 36),
                  const SizedBox(height: 4),
                  Text(
                    isActive ? 'SOS Active' : 'Help',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,

                      color: Colors.white,
                    ),
                  ),
                  if (!isActive)
                    Text(
                      'Hold 1s',
                      style: TextStyle(fontSize: 9, color: Colors.white),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//  SOS Active Dialog
class _SosActiveDialog extends StatefulWidget {
  final String victimName;
  final String flatId;
  final VoidCallback onCancel;

  const _SosActiveDialog({
    required this.victimName,
    required this.flatId,
    required this.onCancel,
  });

  @override
  State<_SosActiveDialog> createState() => _SosActiveDialogState();
}

class _SosActiveDialogState extends State<_SosActiveDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.red.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sos, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            '🚨 SOS Active!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All flat members have been notified.\nYour location is being shared.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 20),

          // Live location stream
          StreamBuilder<List<SosAlertModel>>(
            stream: FirestoreService.getActiveSosAlerts(widget.flatId),
            builder: (context, snap) {
              final alert = snap.data?.where(
                (a) => a.victimName == widget.victimName && a.isActive,
              );
              if (alert == null || alert.isEmpty)
                return const SizedBox.shrink();
              final current = alert.first;
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${current.latitude.toStringAsFixed(4)}, ${current.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
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
                  ],
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              widget.onCancel();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.cancel),
            label: const Text('Cancel SOS'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
