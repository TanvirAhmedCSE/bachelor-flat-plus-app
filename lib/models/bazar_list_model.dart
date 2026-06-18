class BazarListModel {
  final String id;
  final String title;
  final String description;
  final DateTime bazarDate;
  final String addedBy;
  final String addedByName;
  final DateTime addedAt;
  final List<Map<String, dynamic>>
  columns; // [{name: 'Product'}, {name: 'Weight'}, ...]
  final List<Map<String, dynamic>>
  rows; // [{col0: 'Dim', col1: '10', col2: '12', col3: '60'}, ...]
  final List<String> imageUrls;
  final double totalTaka;

  BazarListModel({
    required this.id,
    required this.title,
    required this.description,
    required this.bazarDate,
    required this.addedBy,
    required this.addedByName,
    required this.addedAt,
    required this.columns,
    required this.rows,
    this.imageUrls = const [],
    this.totalTaka = 0,
  });

  factory BazarListModel.fromMap(Map<String, dynamic> map) {
    return BazarListModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      bazarDate: map['bazarDate'] != null
          ? DateTime.parse(map['bazarDate'])
          : DateTime.now(),
      addedBy: map['addedBy'] ?? '',
      addedByName: map['addedByName'] ?? '',
      addedAt: map['addedAt'] != null
          ? DateTime.parse(map['addedAt'])
          : DateTime.now(),
      columns: List<Map<String, dynamic>>.from(
        (map['columns'] ?? []).map((e) => Map<String, dynamic>.from(e)),
      ),
      rows: List<Map<String, dynamic>>.from(
        (map['rows'] ?? []).map((e) => Map<String, dynamic>.from(e)),
      ),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      totalTaka: (map['totalTaka'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'bazarDate': bazarDate.toIso8601String(),
      'addedBy': addedBy,
      'addedByName': addedByName,
      'addedAt': addedAt.toIso8601String(),
      'columns': columns,
      'rows': rows,
      'imageUrls': imageUrls,
      'totalTaka': totalTaka,
    };
  }
}
