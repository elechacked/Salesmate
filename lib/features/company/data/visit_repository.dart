//visit repository .dart

import 'package:get/get.dart';
import 'package:salesmate/core/services/visit_service.dart';
import 'package:salesmate/models/employee_with_visits.dart';
import 'package:salesmate/models/visit_models.dart';

import '../../../core/services/auth_service.dart';

class VisitRepository extends GetxService {
  final VisitService _visitService = Get.find();




  Future<List<EmployeeWithVisits>> getEmployeesWithVisits() async {
    final companyId = await Get.find<AuthService>().getCurrentUserCompanyId();    if (companyId == null) return [];
    return await _visitService.getAllEmployeesWithVisits(companyId);
  }

  Future<List<Visit>> getEmployeeVisits(
      String employeeEmail, {
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    final companyId = await Get.find<AuthService>().getCurrentUserCompanyId();    if (companyId == null) return [];

    return await _visitService.getEmployeeVisits(
      companyId,
      employeeEmail,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<Visit?> getVisitDetails(String employeeEmail, String visitId) async {
    final companyId = await Get.find<AuthService>().getCurrentUserCompanyId();    if (companyId == null) return null;

    return await _visitService.getVisitDetails(companyId, employeeEmail, visitId);
  }

  Future<List<EmployeeWithVisits>> getAllEmployeesWithVisits() async {
    final companyId = await Get.find<AuthService>().getCurrentUserCompanyId();    if (companyId == null) return [];
    return await _visitService.getAllEmployeesWithVisits(companyId);
  }
}