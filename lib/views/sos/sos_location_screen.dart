import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/sos_alert_model.dart';
import '../../services/firestore_service.dart';

class SosLocationScreen extends StatefulWidget {
  final SosAlertModel alert;

  const SosLocationScreen({super.key, required this.alert});

  @override
  State<SosLocationScreen> createState() => _SosLocationScreenState();
}

class _SosLocationScreenState extends State<SosLocationScreen> {
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _animateToLocation(double lat, double lng) {
    try {
      _mapController.move(LatLng(lat, lng), 16.0);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        title: const Text('🚨 SOS — Live Location'),
      ),
      body: StreamBuilder<List<SosAlertModel>>(
        stream: FirestoreService.getActiveSosAlerts(widget.alert.flatId),
        builder: (context, snap) {
          SosAlertModel current = widget.alert;
          if (snap.hasData) {
            final found = snap.data!.where((a) => a.id == widget.alert.id);
            if (found.isNotEmpty) {
              final updated = found.first;

              if (updated.latitude != current.latitude ||
                  updated.longitude != current.longitude) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _animateToLocation(updated.latitude, updated.longitude);
                });
              }
              current = updated;
            }
          }

          final mapsLink =
              'https://maps.google.com/?q=${current.latitude},${current.longitude}';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //  Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.sos, color: Colors.white, size: 56),
                      const SizedBox(height: 12),
                      Text(
                        current.victimName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'triggered SOS at ${DateFormat('hh:mm a').format(current.triggeredAt)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (!current.isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '✓ SOS Cancelled',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                //  Location info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.red.shade400,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Live Location',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const Spacer(),
                          if (current.isActive) ...[
                            _LivePulse(),
                            const SizedBox(width: 4),
                            const Text(
                              'Live',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      _coordRow(
                        'Latitude',
                        current.latitude.toStringAsFixed(6),
                      ),
                      const SizedBox(height: 4),
                      _coordRow(
                        'Longitude',
                        current.longitude.toStringAsFixed(6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                //  Live Map (flutter_map + OpenStreetMap)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 260,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: LatLng(
                          current.latitude,
                          current.longitude,
                        ),
                        initialZoom: 16.0,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                      ),
                      children: [
                        // OpenStreetMap tile layer
                        TileLayer(
                          urlTemplate:
                              'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c', 'd'],
                          userAgentPackageName: 'com.example.bachelor_flat_app',
                        ),
                        // Live marker
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                current.latitude,
                                current.longitude,
                              ),
                              width: 48,
                              height: 48,
                              child: _SosPulsingMarker(
                                isActive: current.isActive,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 12,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Map updates automatically every 5 seconds',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                //  Buttons
                ElevatedButton.icon(
                  onPressed: () => _launch(mapsLink),
                  icon: const Icon(Icons.map),
                  label: const Text('Open in Google Maps'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    final whatsapp =
                        'https://wa.me/?text=🚨 SOS! ${current.victimName} needs help! Location: $mapsLink';
                    _launch(whatsapp);
                  },
                  icon: const Icon(Icons.share, color: Colors.green),
                  label: const Text(
                    'Share Location via WhatsApp',
                    style: TextStyle(color: Colors.green),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _coordRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

//  Pulsing red marker
class _SosPulsingMarker extends StatefulWidget {
  final bool isActive;
  const _SosPulsingMarker({required this.isActive});

  @override
  State<_SosPulsingMarker> createState() => _SosPulsingMarkerState();
}

class _SosPulsingMarkerState extends State<_SosPulsingMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return const Icon(Icons.location_on, color: Colors.grey, size: 40);
    }
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.scale(
        scale: _anim.value,
        child: const Icon(Icons.location_on, color: Colors.red, size: 44),
      ),
    );
  }
}

//  Small live pulse dot
class _LivePulse extends StatefulWidget {
  @override
  State<_LivePulse> createState() => _LivePulseState();
}

class _LivePulseState extends State<_LivePulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.5 + _ctrl.value * 0.5),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
