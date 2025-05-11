import 'package:salesmate/features/superadmin/domain/entities/user_entity.dart';
import 'package:salesmate/features/superadmin/data/datasources/user_remote_datasource.dart';

class UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepository({required this.remoteDataSource});

  Future<List<UserEntity>> getUsers() async {
    return await remoteDataSource.getUsers();
  }

  Future<UserEntity> getUserDetails(String email) async {
    if (email.isEmpty) {
      throw Exception('Email cannot be empty');
    }
    return await remoteDataSource.getUserDetails(email);
  }

  Future<void> toggleUserStatus(String email, bool newStatus) async {
    if (email.isEmpty) {
      throw Exception('Email cannot be empty');
    }
    return await remoteDataSource.toggleUserStatus(email, newStatus);
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
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password cannot be empty');
    }
    if (role.isEmpty) {
      throw Exception('Role cannot be empty');
    }
    return await remoteDataSource.createUser(
      email: email,
      password: password,
      companyId: companyId,
      isActive: isActive,
      name: name,
      phone: phone,
    );
  }



}