import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:salesmate/models/employee_with_visits.dart';
import '../../../../models/employee_models.dart';
import '../../../../models/visit_models.dart';
import '../data/visit_repository.dart';

class VisitController extends GetxController {
  final VisitRepository _repository = Get.find<VisitRepository>();

  // State variables
  var isLoading = false.obs;
  var employeesWithVisits = <EmployeeWithVisits>[].obs;
  var selectedEmployee = Rxn<Employee>();
  var employeeVisits = <Visit>[].obs;
  var selectedVisit = Rxn<Visit>();
  var dateRange = Rxn<DateTimeRange>();

  // Search/filter variables
  var searchQuery = ''.obs;
  var filterOngoing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadEmployeesWithVisits();
  }

  Future<void> loadEmployeesWithVisits() async {
    try {
      isLoading(true);
      final result = await _repository.getEmployeesWithVisits();
      employeesWithVisits.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<List<EmployeeWithVisits>> getAllEmployeesWithVisits() async {
    try {
      isLoading(true);
      final result = await _repository.getAllEmployeesWithVisits();
      return result;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return [];
    } finally {
      isLoading(false);
    }
  }

  List<Employee> get employees => employeesWithVisits
      .map((employeeWithVisits) => employeeWithVisits.employee)
      .toList();

  Future<void> loadEmployeeVisits(String employeeEmail) async {
    try {
      isLoading(true);
      // Find and set the selected employee
      selectedEmployee.value = employeesWithVisits.firstWhere(
            (e) => e.employee.email == employeeEmail,
      ).employee;

      DateTime? startDate;
      DateTime? endDate;

      if (dateRange.value != null) {
        startDate = dateRange.value!.start;
        endDate = dateRange.value!.end;
      }

      final visits = await _repository.getEmployeeVisits(
        employeeEmail,
        startDate: startDate,
        endDate: endDate,
      );

      employeeVisits.assignAll(visits.where((v) {
        if (filterOngoing.value) return v.isOngoing;
        return true;
      }));
    } catch (e) {
      Get.snackbar('Error', 'Failed to load visits: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadVisitDetails(String visitId) async {
    try {
      isLoading(true);
      final visit = await _repository.getVisitDetails(
        selectedEmployee.value!.email,
        visitId,
      );
      selectedVisit.value = visit;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load visit details: $e');
    } finally {
      isLoading(false);
    }
  }

  void applyFilters() {
    if (selectedEmployee.value != null) {
      loadEmployeeVisits(selectedEmployee.value!.email);
    }
  }

  void clearFilters() {
    searchQuery.value = '';
    filterOngoing.value = false;
    dateRange.value = null;
    applyFilters();
  }

  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }
}