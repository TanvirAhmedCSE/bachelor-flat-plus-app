class ActivityLogModel {
  final String id;
  final String type;
  final String by;
  final String byName;
  final String message;
  final DateTime timestamp;
  final String? relatedId;

  ActivityLogModel({
    required this.id,
    required this.type,
    required this.by,
    required this.byName,
    required this.message,
    required this.timestamp,
    this.relatedId,
  });

  factory ActivityLogModel.fromMap(Map<String, dynamic> map) {
    return ActivityLogModel(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      by: map['by'] ?? '',
      byName: map['byName'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      relatedId: map['relatedId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'by': by,
      'byName': byName,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'relatedId': relatedId,
    };
  }
}
