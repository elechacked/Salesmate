// lib/models/user_models.dart
import 'package:cloud_firestore/cloud_firestore.dart';


class UserModel {
 final String email;
 final String role;
 final String? companyId;
 final bool isActive;

  UserModel({
    required this.email,
    required this.role,
    this.companyId,
    this.isActive = true,
  });

  // Add these factory methods if you need to create from Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      email: doc.id,
      role: data['role']?.toString() ?? '',
      companyId: data['companyId']?.toString(),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'role': role,
      if (companyId != null) 'companyId': companyId,
      'isActive': isActive,
    };
  }
}