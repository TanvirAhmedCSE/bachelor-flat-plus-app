class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String flatId;
  final String? photoUrl;
  final DateTime joinedAt;
  final String status;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.flatId,
    this.photoUrl,
    required this.joinedAt,
    this.status = 'active',
  });

  bool get isAdmin => role == 'admin';
  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
  bool get isRemoved => status == 'removed';

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'member',
      flatId: map['flatId'] ?? '',
      photoUrl: map['photoUrl'],
      joinedAt: map['joinedAt'] != null
          ? DateTime.parse(map['joinedAt'])
          : DateTime.now(),
      status: map['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'flatId': flatId,
      'photoUrl': photoUrl,
      'joinedAt': joinedAt.toIso8601String(),
      'status': status,
    };
  }
}
