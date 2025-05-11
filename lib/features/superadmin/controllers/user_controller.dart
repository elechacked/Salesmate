import 'package:get/get.dart';
import 'package:salesmate/features/superadmin/domain/entities/user_entity.dart';
import 'package:salesmate/features/superadmin/domain/usecases/manage_user.dart';

class UserController extends GetxController {
  final ManageUser _manageUser;

  UserController({required ManageUser manageUser}) : _manageUser = manageUser;

  final RxList<UserEntity> users = <UserEntity>[].obs;
  final Rx<UserEntity?> currentUser = Rx<UserEntity?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    fetchUsers();
    super.onInit();
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await _manageUser.getUsers();
      users.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getUserDetails(String email) async {
    try {
      isLoading.value = true;
      currentUser.value = null;
      final user = await _manageUser.getUserDetails(email);
      currentUser.value = user;
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleUserStatus(String email, bool currentStatus) async {
    try {
      isLoading.value = true;
      await _manageUser.toggleUserStatus(email, !currentStatus);

      // Update local list
      final index = users.indexWhere((user) => user.email == email);
      if (index != -1) {
        users[index] = users[index].copyWith(isActive: !currentStatus);
      }

      // Update current user if it's the one being toggled
      if (currentUser.value?.email == email) {
        currentUser.value = currentUser.value?.copyWith(isActive: !currentStatus);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> createUser({
    required String email,
    required String password,
    String? companyId,
    required bool isActive,
    String? name,
    String? phone,
  }) async {
    try {
      isLoading.value = true;
      await _manageUser.createUser(
        email: email,
        password: password,
        companyId: companyId,
        isActive: isActive,
        name: name,
        phone: phone,
        role: '',
      );
      await fetchUsers(); // Refresh the list
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}