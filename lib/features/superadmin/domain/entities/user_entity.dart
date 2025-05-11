import 'package:cloud_firestore/cloud_firestore.dart';

class UserEntity {
  final String email;
  final String role;
  final String? companyId;
  final bool isActive;
  final DateTime createdAt;
  final String? name;
  final String? phone;

  UserEntity({
    required this.email,
    required this.role,
    this.companyId,
    required this.isActive,
    required this.createdAt,
    this.name,
    this.phone,
  });

  factory UserEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserEntity(
      email: doc.id,
      role: data['role']?.toString() ?? 'employee',
      companyId: data['companyId']?.toString(),
      isActive: data['isActive'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      name: data['name']?.toString(),
      phone: data['phone']?.toString(),
    );
  }

  UserEntity copyWith({
    String? email,
    String? role,
    String? companyId,
    bool? isActive,
    DateTime? createdAt,
    String? name,
    String? phone,
  }) {
    return UserEntity(
      email: email ?? this.email,
      role: role ?? this.role,
      companyId: companyId ?? this.companyId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      phone: phone ?? this.phone,
    );
  }
}