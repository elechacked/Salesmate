import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salesmate/features/superadmin/domain/entities/user_entity.dart';

class UserRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UserRemoteDataSource({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;



  Future<List<UserEntity>> getUsers() async {
    try {
      final snapshot = await _firestore.collection('auth_profiles').get();
      return snapshot.docs
          .map((doc) => UserEntity.fromFirestore(doc))
          .where((user) => user.role != 'superadmin') // Filter out superadmins
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch users: ${e.toString()}');
    }
  }

  Future<UserEntity> getUserDetails(String email) async {
    try {
      final doc = await _firestore.collection('auth_profiles').doc(email).get();
      if (!doc.exists) {
        throw Exception('User not found');
      }
      return UserEntity.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch user details: ${e.toString()}');
    }
  }

  Future<void> toggleUserStatus(String email, bool newStatus) async {
    try {
      // First check if user is superadmin
      final doc = await _firestore.collection('auth_profiles').doc(email).get();
      if (!doc.exists) throw Exception('User not found');
      if (doc.data()?['role'] == 'superadmin') {
        throw Exception('Cannot modify superadmin status');
      }

      await _firestore.collection('auth_profiles').doc(email).update({
        'isActive': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to toggle user status: ${e.toString()}');
    }
  }

  Future<void> createUser({
    required String email,
    required String password,
    String? companyId,
    required bool isActive,
    String? name,
    String? phone,
  }) async{
    try {
      // Create in Firebase Auth
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create in Firestore with hardcoded 'company' role
      await _firestore.collection('auth_profiles').doc(email).set({
        'role': 'company', // Only company role allowed
        if (companyId != null) 'companyId': companyId,
        'isActive': isActive,
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw Exception('Authentication error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create user: ${e.toString()}');
    }
  }

}