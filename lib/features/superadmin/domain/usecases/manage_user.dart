import 'package:salesmate/features/superadmin/data/repositories/user_repository.dart';
import 'package:salesmate/features/superadmin/domain/entities/user_entity.dart';

class ManageUser {
  final UserRepository repository;

  ManageUser({required this.repository});

  Future<List<UserEntity>> getUsers() async {
    return await repository.getUsers();
  }

  Future<UserEntity> getUserDetails(String email) async {
    return await repository.getUserDetails(email);
  }

  Future<void> toggleUserStatus(String email, bool newStatus) async {
    return await repository.toggleUserStatus(email, newStatus);
  }

  Future<void> createUser({
    required String email,
    required String password,
    required String role,
    String? companyId,
    required bool isActive,
    String? name,
    String? phone,
  }) async {
    return await repository.createUser(
      email: email,
      password: password,
      role: role,
      companyId: companyId,
      isActive: isActive,
      name: name,
      phone: phone,
    );
  }

}