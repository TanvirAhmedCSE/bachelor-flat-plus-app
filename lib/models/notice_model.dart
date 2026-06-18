class NoticeModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String addedBy;
  final String addedByName;
  final DateTime addedAt;
  final List<String> imageUrls;

  NoticeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.addedBy,
    required this.addedByName,
    required this.addedAt,
    this.imageUrls = const [],
  });

  factory NoticeModel.fromMap(Map<String, dynamic> map) {
    return NoticeModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Others',
      addedBy: map['addedBy'] ?? '',
      addedByName: map['addedByName'] ?? '',
      addedAt: map['addedAt'] != null
          ? DateTime.parse(map['addedAt'])
          : DateTime.now(),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'addedBy': addedBy,
      'addedByName': addedByName,
      'addedAt': addedAt.toIso8601String(),
      'imageUrls': imageUrls,
    };
  }
}
