// lib/core/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:salesmate/models/user_models.dart';

class UserService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get authProfiles => _firestore.collection('auth_profiles');

  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final doc = await authProfiles.doc(email).get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>? ?? {};
      final isActive = data['isActive'] as bool? ?? false;

      if (!isActive) {
        throw 'Your account has been disabled by the system';
      }

      return UserModel(
        email: email,
        role: data['role']?.toString() ?? 'employee',
        companyId: data['companyId']?.toString(),
        isActive: isActive,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createAuthProfile(UserModel user) async {
    await authProfiles.doc(user.email).set(user.toFirestore());
  }
}