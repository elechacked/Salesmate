// lib/models/employee_with_visits.dart
import 'package:salesmate/models/employee_models.dart';
import 'package:salesmate/models/visit_models.dart';



class EmployeeWithVisits {
   final Employee employee;
   final List<Visit> visits;
   final int totalVisits;

  EmployeeWithVisits({
    required this.employee,
    required this.visits,
    required this.totalVisits,
  });

  // Helper method to check if employee has any visits
  bool get hasVisits => visits.isNotEmpty;

  // Get last visit date if available
  String? get lastVisitDate {
    if (visits.isEmpty) return null;
    final lastVisit = visits.first;
    return '${lastVisit.checkInTime.day}/${lastVisit.checkInTime.month}/${lastVisit.checkInTime.year}';
  }
}