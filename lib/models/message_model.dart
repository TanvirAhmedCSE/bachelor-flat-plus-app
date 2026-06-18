class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String? imageUrl;
  final String? text;
  final String type; // 'text' or 'image'
  final DateTime timestamp;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.imageUrl,
    this.text,
    required this.type,
    required this.timestamp,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      imageUrl: map['imageUrl'],
      text: map['text'],
      type: map['type'] ?? 'text',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'imageUrl': imageUrl,
      'text': text,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
