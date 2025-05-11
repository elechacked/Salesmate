//visit services

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:salesmate/models/visit_models.dart';

import '../../models/employee_models.dart';
import '../../models/employee_with_visits.dart';

class VisitService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxBool visitsNeedRefresh = false.obs;

  // Call this after any visit modification

  CollectionReference visits(String companyId, String employeeEmail) =>
      _firestore
          .collection('companies')
          .doc(companyId)
          .collection('employees')
          .doc(employeeEmail)
          .collection('visits');

  Future<void> createVisit(Visit visit) async {
    try {
      await _firestore
          .collection('companies')
          .doc(visit.companyId)
          .collection('employees')
          .doc(visit.employeeEmail)
          .collection('visits')
          .add(visit.toFirestore());

      visitsNeedRefresh.toggle();
    } catch (e) {
      throw Exception('Failed to create visit');
    }
  }

  Future<void> updateVisit(Visit visit) async {
    try {
      await _firestore
          .collection('companies')
          .doc(visit.companyId)
          .collection('employees')
          .doc(visit.employeeEmail)
          .collection('visits')
          .doc(visit.id)
          .update(visit.toFirestore());

      visitsNeedRefresh.toggle(); // Notify listeners
    } catch (e) {
      throw Exception('Failed to update visit');
    }
  }

  Future<Visit?> getOngoingVisit(String companyId, String employeeEmail) async {
    final query = await visits(companyId, employeeEmail)
        .where('checkOutTime', isNull: true)
        .limit(1)
        .get();

    return query.docs.isNotEmpty
        ? Visit.fromFirestore(query.docs.first)
        : null;
  }

  Future<List<Visit>> getAllCompanyVisits(String companyId) async {
    final employeesSnapshot = await _firestore
        .collection('companies')
        .doc(companyId)
        .collection('employees')
        .get();

    final allVisits = <Visit>[];
    for (final employeeDoc in employeesSnapshot.docs) {
      final visitsSnapshot = await visits(companyId, employeeDoc.id)
          .orderBy('checkInTime', descending: true)
          .get();
      allVisits.addAll(visitsSnapshot.docs.map((doc) => Visit.fromFirestore(doc)));
    }
    return allVisits;
  }

  Future<List<Visit>> getActiveVisits(String companyId) async {
    final employeesSnapshot = await _firestore
        .collection('companies')
        .doc(companyId)
        .collection('employees')
        .get();

    final activeVisits = <Visit>[];
    for (final employeeDoc in employeesSnapshot.docs) {
      final query = await visits(companyId, employeeDoc.id)
          .where('checkOutTime', isNull: true)
          .get();
      activeVisits.addAll(query.docs.map((doc) => Visit.fromFirestore(doc)));
    }
    return activeVisits;
  }


  Future<int> getEmployeeVisitsCount(String companyId, String employeeEmail) async {
    final snapshot = await visits(companyId, employeeEmail).count().get();
    return snapshot.count ?? 0;
  }

  Future<List<Visit>> getEmployeeVisits(
      String companyId,
      String employeeEmail, {
        int? limit,
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    Query query = visits(companyId, employeeEmail)
        .orderBy('checkInTime', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    if (startDate != null && endDate != null) {
      query = query
          .where('checkInTime', isGreaterThanOrEqualTo: startDate)
          .where('checkInTime', isLessThanOrEqualTo: endDate);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Visit.fromFirestore(doc)).toList();
  }

  Future<Visit?> getVisitDetails(
      String companyId,
      String employeeEmail,
      String visitId,
      ) async {
    final doc = await visits(companyId, employeeEmail).doc(visitId).get();
    return doc.exists ? Visit.fromFirestore(doc) : null;
  }

  Future<List<EmployeeWithVisits>> getAllEmployeesWithVisits(String companyId) async {
    final employeesSnapshot = await _firestore
        .collection('companies')
        .doc(companyId)
        .collection('employees')
        .get();

    final result = <EmployeeWithVisits>[];

    for (final employeeDoc in employeesSnapshot.docs) {
      final employee = Employee.fromFirestore(employeeDoc);
      final visits = await getEmployeeVisits(companyId, employeeDoc.id, limit: 5);

      result.add(EmployeeWithVisits(
        employee: employee,
        visits: visits,
        totalVisits: await getEmployeeVisitsCount(companyId, employeeDoc.id),
      ));
    }

    return result;
  }
}