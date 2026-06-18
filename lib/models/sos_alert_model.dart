class SosAlertModel {
  final String id;
  final String victimUid;
  final String victimName;
  final String flatId;
  final double latitude;
  final double longitude;
  final DateTime triggeredAt;
  final bool isActive;

  SosAlertModel({
    required this.id,
    required this.victimUid,
    required this.victimName,
    required this.flatId,
    required this.latitude,
    required this.longitude,
    required this.triggeredAt,
    this.isActive = true,
  });

  factory SosAlertModel.fromMap(Map<String, dynamic> map) {
    return SosAlertModel(
      id: map['id'] ?? '',
      victimUid: map['victimUid'] ?? '',
      victimName: map['victimName'] ?? '',
      flatId: map['flatId'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      triggeredAt: map['triggeredAt'] != null
          ? DateTime.parse(map['triggeredAt'])
          : DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'victimUid': victimUid,
      'victimName': victimName,
      'flatId': flatId,
      'latitude': latitude,
      'longitude': longitude,
      'triggeredAt': triggeredAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  SosAlertModel copyWith({
    double? latitude,
    double? longitude,
    bool? isActive,
  }) {
    return SosAlertModel(
      id: id,
      victimUid: victimUid,
      victimName: victimName,
      flatId: flatId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      triggeredAt: triggeredAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
