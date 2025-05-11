// employee services.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:salesmate/models/employee_models.dart';

import 'auth_service.dart';

class EmployeeService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference employees(String companyId) =>
      _firestore.collection('companies').doc(companyId).collection('employees');

  CollectionReference get authProfiles => _firestore.collection('auth_profiles');

  // Existing functions (unchanged)
  Future<Employee?> getEmployee(String companyId, String email) async {
    final doc = await employees(companyId).doc(email).get();
    return doc.exists ? Employee.fromFirestore(doc) : null;
  }

  Future<void> updateEmployeeProfile(Employee employee) async {
    await employees(employee.companyId)
        .doc(employee.email)
        .update(employee.toFirestore());
  }

  // New functions
  Future<List<Employee>> getAllEmployees() async {
    final companyId = await Get.find<AuthService>().getCurrentUserCompanyId();
    if (companyId == null) return [];

    final snapshot = await employees(companyId).get();
    return snapshot.docs.map((doc) => Employee.fromFirestore(doc)).toList();
  }

  Future<bool> canAddMoreEmployees() async {
    final companyId = await Get.find<AuthService>().getCurrentUserCompanyId();
    if (companyId == null) return false;

    final company = await _firestore.collection('companies').doc(companyId).get();
    final employeesCount = await employees(companyId).count().get();

    return employeesCount.count! < (company.data()?['maxUsers'] ?? 0);
  }

  Future<void> createEmployee({
    required Employee employee,
    required String password,
  }) async {
    // Create auth user
    await _auth.createUserWithEmailAndPassword(
      email: employee.email,
      password: password,
    );

    // Create auth profile
    await authProfiles.doc(employee.email).set({
      'email': employee.email,
      'role': 'employee',
      'companyId': employee.companyId,
      'isActive': true,
    });

    // Create employee record
    await employees(employee.companyId)
        .doc(employee.email)
        .set(employee.toFirestore());
  }

  Future<void> deleteEmployee(String email) async {
    final companyId = await Get.find<AuthService>().getCurrentUserCompanyId();
    if (companyId == null) return;

    // Delete auth user
    try {
      final user = await _auth.fetchSignInMethodsForEmail(email);
      if (user.isNotEmpty) {
        await _auth.currentUser?.delete();
      }
    } catch (e) {
      Get.log('Error deleting auth user: $e');
    }

    // Delete records
    await Future.wait([
      authProfiles.doc(email).delete(),
      employees(companyId).doc(email).delete(),
    ]);
  }

  Future<void> toggleEmployeeStatus(Employee employee) async {
    await employees(employee.companyId)
        .doc(employee.email)
        .update({'isActive': !employee.isActive});
  }

  Future<bool> employeeExists(String email, String companyId) async {
    final doc = await employees(companyId).doc(email).get();
    return doc.exists;
  }


}