import 'package:get/get.dart';

import '../data/auth_repository.dart';
import '../../../models/user_models.dart';

class AuthController extends GetxController {
  final AuthRepository _repository = Get.find<AuthRepository>();
  final Rx<AuthStatus> _status = AuthStatus.unauthenticated.obs;

  AuthStatus get status => _status.value;
  UserModel? get currentUser => _repository.user;
  String? get userRole => _repository.user?.role;
  String? get companyId => _repository.user?.companyId;
  String? get userEmail => _repository.user?.email;

  Future<void> login(String email, String password) async {
    try {
      _status.value = AuthStatus.authenticating;
      await _repository.signInWithCredentials(email, password);
      _status.value = AuthStatus.authenticated;
    } catch (e) {
      _status.value = AuthStatus.unauthenticated;
      throw e.toString().contains('disabled')
          ? e.toString()
          : 'Login failed. Please check your credentials.';
    }
  }

  Future<void> tryAutoLogin() async {
    try {
      _status.value = AuthStatus.authenticating;
      await _repository.silentSignIn();
      _status.value = _repository.user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    } catch (e) {
      _status.value = AuthStatus.unauthenticated;
    }
  }

  Future<void> logout() async {
    try {
      _status.value = AuthStatus.unauthenticating;
      await _repository.signOut();
      _status.value = AuthStatus.unauthenticated;
    } catch (e) {
      _status.value = AuthStatus.unauthenticated;
      rethrow;
    }
  }

  void updateUser(UserModel user) {
    _repository.user = user;
    _status.value = AuthStatus.authenticated;
  }
}

enum AuthStatus {
  unauthenticated,
  authenticating,
  authenticated,
  unauthenticating
}