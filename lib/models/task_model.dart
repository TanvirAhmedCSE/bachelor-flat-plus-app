class TaskModel {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final String createdByName;
  final String status;
  final DateTime dueDate;
  final DateTime createdAt;
  final List<String> assignedTo;
  final List<String> assignedToNames;
  final List<String> completedBy;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.createdByName,
    required this.status,
    required this.dueDate,
    required this.createdAt,
    this.assignedTo = const [],
    this.assignedToNames = const [],
    this.completedBy = const [],
  });

  bool get isFullyCompleted =>
      assignedTo.isNotEmpty &&
      assignedTo.every((uid) => completedBy.contains(uid));

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdByName: map['createdByName'] ?? '',
      status: map['status'] ?? 'pending',
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'])
          : DateTime.now(),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      assignedTo: List<String>.from(map['assignedTo'] ?? []),
      assignedToNames: List<String>.from(map['assignedToNames'] ?? []),
      completedBy: List<String>.from(map['completedBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'status': status,
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'assignedTo': assignedTo,
      'assignedToNames': assignedToNames,
      'completedBy': completedBy,
    };
  }
}
