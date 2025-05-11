//company employee repository.dart

import 'package:get/get.dart';
import 'package:salesmate/core/services/employee_service.dart';
import 'package:salesmate/models/employee_models.dart';

class CompanyEmployeeRepository extends GetxService {
  final EmployeeService _employeeService = Get.find();

  Future<List<Employee>> getEmployees() async {
    return await _employeeService.getAllEmployees();
  }

  Future<bool> canAddMoreEmployees() async {
    return await _employeeService.canAddMoreEmployees();
  }

  Future<void> createEmployee({
    required Employee employee,
    required String password,
  }) async {
    await _employeeService.createEmployee(
      employee: employee,
      password: password,
    );
  }

  Future<void> updateEmployee(Employee employee) async {
    await _employeeService.updateEmployeeProfile(employee);
  }

  Future<void> deleteEmployee(String email) async {
    await _employeeService.deleteEmployee(email);
  }

  Future<void> toggleEmployeeStatus(Employee employee) async {
    await _employeeService.toggleEmployeeStatus(employee);
  }
}