// lib/features/employee/controller/employee_profile_controller.dart
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salesmate/core/services/employee_service.dart';
import 'package:salesmate/core/utils/upload_utils.dart';
import 'package:salesmate/models/employee_models.dart';

import '../../auth/controller/auth_controller.dart';

class EmployeeProfileController extends GetxController {
  final EmployeeService _employeeService = Get.find<EmployeeService>();
  final Rx<Employee?> employee = Rx<Employee?>(null);
  final RxString avatarUrl = ''.obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final user = Get.find<AuthController>().currentUser;
      if (user == null || user.companyId == null) return;

      employee.value = await _employeeService.getEmployee(
        user.companyId!,
        user.email,
      );

      if (employee.value?.profileImageUrl != null) {
        avatarUrl.value = employee.value!.profileImageUrl!;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load profile: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfileImage(ImageSource source) async {
    try {
      final user = Get.find<AuthController>().currentUser;
      if (user == null || user.companyId == null) return;

      final imageFile = await UploadUtils.pickAndCompressImage(source);
      if (imageFile == null) return;

      isLoading.value = true;

      final downloadUrl = await UploadUtils.uploadImage(
        type: UploadType.profilePicture,
        imageFile: imageFile,
        metadata: {
          'companyId': user.companyId!,
          'email': user.email,
        },
      );

      await _employeeService.updateEmployeeProfile(
        Employee(
          email: user.email,
          name: employee.value?.name ?? '',
          phone: employee.value?.phone ?? '',
          companyId: user.companyId!,
          isActive: employee.value?.isActive ?? true,
          createdAt: employee.value?.createdAt ?? DateTime.now(),
          profileImageUrl: downloadUrl,
          department: employee.value?.department,
          designation: employee.value?.designation,
        ),
      );

      avatarUrl.value = downloadUrl;
      Get.snackbar('Success', 'Profile image updated');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}