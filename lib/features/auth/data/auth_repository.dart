// lib/features/auth/data/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/employee_service.dart';
import '../../../core/services/user_service.dart';
import '../../../models/user_models.dart';

class AuthRepository {
  final AuthService _authService = Get.find<AuthService>();
  final UserService _userService = Get.find<UserService>();
  final EmployeeService _employeeService = Get.find<EmployeeService>();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const _authTokenKey = 'auth_token';
  static const _userEmailKey = 'user_email';
  static const _userRoleKey = 'user_role';
  static const _companyIdKey = 'company_id';

  UserModel? _cachedUser;
  String? _cachedToken;

  UserModel? get user => _cachedUser;
  String? get token => _cachedToken;

  set user(UserModel? user) => _cachedUser = user;
  set token(String? token) => _cachedToken = token;

  Future<void> _persistAuthData(String token, UserModel user) async {
    await Future.wait([
      _secureStorage.write(key: _authTokenKey, value: token),
      _secureStorage.write(key: _userEmailKey, value: user.email),
      _secureStorage.write(key: _userRoleKey, value: user.role),
      if (user.companyId != null)
        _secureStorage.write(key: _companyIdKey, value: user.companyId),
    ]);
  }

  Future<void> _clearPersistedAuth() async {
    _cachedToken = null;
    _cachedUser = null;
    await _secureStorage.deleteAll();
  }

  Future<bool> hasValidToken() async {
    return await _secureStorage.read(key: _authTokenKey) != null;
  }

  Future<UserModel> signInWithCredentials(String email, String password) async {
    try {
      final userCredential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) throw 'Authentication failed';

      final token = await firebaseUser.getIdToken();
      final userProfile = await _userService.getUserByEmail(email);

      if (userProfile == null) {
        await _authService.signOut();
        throw 'User profile not found. Contact admin.';
      }

      if (userProfile.role.toLowerCase() == 'employee' && userProfile.companyId != null) {
        final employee = await _employeeService.getEmployee(userProfile.companyId!, email);
        if (employee == null || !employee.isActive) {
          throw 'Your account is disabled. Please contact your supervisor.';
        }
      }

      _cachedUser = userProfile;
      _cachedToken = token;

      if (_cachedToken != null) {
        await _persistAuthData(_cachedToken!, userProfile);
      }

      return userProfile;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> silentSignIn() async {
    try {
      final email = await _secureStorage.read(key: _userEmailKey);
      if (email == null) throw Exception('No saved email found');

      await _authService.currentUser?.reload();
      _cachedToken = await _secureStorage.read(key: _authTokenKey);

      final role = await _secureStorage.read(key: _userRoleKey);
      _cachedUser = role != null
          ? UserModel(
        email: email,
        role: role,
        companyId: await _secureStorage.read(key: _companyIdKey),
      )
          : await _userService.getUserByEmail(email);
    } catch (e) {
      await _clearPersistedAuth();
      throw Exception('Silent login failed');
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    await _clearPersistedAuth();
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'No user found with this email.';
      case 'wrong-password': return 'Wrong password provided.';
      case 'invalid-email': return 'The email address is invalid.';
      case 'user-disabled': return 'This user has been disabled.';
      default: return 'Login failed. Please try again.';
    }
  }
}