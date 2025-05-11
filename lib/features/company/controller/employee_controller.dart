// lib/features/company/controllers/employee_controller.dart
import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salesmate/core/services/employee_service.dart';
import 'package:salesmate/core/utils/upload_utils.dart';
import 'package:salesmate/models/employee_models.dart';

import '../../../core/services/company_service.dart';
import '../../../core/services/user_service.dart';

class EmployeeController extends GetxController {
  final EmployeeService _employeeService = Get.find();
  final UserService _userService = Get.find();
  final CompanyService _companyService = Get.find();

  final RxList<Employee> employees = <Employee>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool canAddMore = false.obs;
  final maxUsers = 0.obs;




  @override
  void onInit() {
    super.onInit();
    loadCompanyDetails();
    loadEmployees();
  }

  Future<void> loadCompanyDetails() async {
    try {
      final company = await _companyService.getCurrentUserCompany();
      if (company != null) {
        maxUsers.value = company.maxUsers;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load company details');
    }
  }


  Future<void> loadEmployees() async {
    try {
      isLoading(true);
      employees.value = await _employeeService.getAllEmployees();
      canAddMore.value = employees.length < maxUsers.value;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load employees');
    } finally {
      isLoading(false);
    }
  }

  Future<bool> canAccessEmployee(String email) async {
    try {
      final user = await _userService.getUserByEmail(email);
      return user?.isActive ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> addEmployee(Employee employee, String password, ) async {
    try {
      isLoading.value = true;

      // Upload image if selected
      String? imageUrl;
      if (selectedImage.value != null) {
        imageUrl = await UploadUtils.uploadImage(
          type: UploadType.profilePicture,
          imageFile: selectedImage.value!,
          metadata: {
            'companyId': employee.companyId,
            'email': employee.email,
          },
        );
      }

      final employeeWithImage = employee.copyWith(
        profileImageUrl: imageUrl,
        companyId: employee.companyId, // Make sure companyId is provided
      );

      await _employeeService.createEmployee(
        employee: employeeWithImage,
        password: password,
      );

      employees.add(employeeWithImage);
      canAddMore.value = await _employeeService.canAddMoreEmployees();
      Get.back();
      Get.snackbar('Success', 'Employee added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add employee');
    } finally {
      isLoading.value = false;
      selectedImage.value = null;
    }
  }

  Future<void> updateEmployee(Employee employee) async {
    try {
      isLoading.value = true;
      await _employeeService.updateEmployeeProfile(employee);
      await loadEmployees();
      Get.back();
      Get.snackbar('Success', 'Employee updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update employee');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleEmployeeStatus(Employee employee) async {
    try {
      isLoading.value = true;
      await _employeeService.toggleEmployeeStatus(employee);
      await loadEmployees();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteEmployee(String email) async {
    try {
      isLoading.value = true;
      await _employeeService.deleteEmployee(email);
      employees.removeWhere((e) => e.email == email);
      canAddMore.value = await _employeeService.canAddMoreEmployees();
      Get.snackbar('Success', 'Employee deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete employee');
    } finally {
      isLoading.value = false;
    }
  }

  final Rx<File?> selectedImage = Rx<File?>(null);

  Future<void> pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image');
    }
  }
}