import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:salesmate/features/superadmin/domain/entities/analytics_entity.dart';

class AnalyticsRepository {
  final FirebaseFirestore firestore;

  AnalyticsRepository({required this.firestore});

  Future<AnalyticsEntity> getPlatformAnalytics(
      {DateTimeRange? dateRange}) async {
    final companiesQuery = firestore.collection('companies');

    // Convert counts to int explicitly
    final companiesCount = (await companiesQuery.count().get()).count!.toInt();
    final activeCompaniesCount = (await companiesQuery
        .where('isActive', isEqualTo: true)
        .count()
        .get()).count!.toInt();

    return AnalyticsEntity(
      totalCompanies: companiesCount,
      activeCompanies: activeCompaniesCount,
      totalEmployees: await _getTotalEmployees(companiesQuery),
      totalVisits: await _getTotalVisits(companiesQuery, dateRange),
      activeVisits: await _getActiveVisits(companiesQuery, dateRange),
    );
  }

  Future<int> _getTotalEmployees(CollectionReference companiesQuery) async {
    var total = 0;
    final companies = await companiesQuery.get();
    for (final company in companies.docs) {
      total += (await companiesQuery.doc(company.id)
          .collection('employees')
          .count()
          .get()).count!.toInt();
    }
    return total;
  }

  Future<int> _getTotalVisits(CollectionReference companiesQuery,
      DateTimeRange? dateRange) async {
    var total = 0;
    final companies = await companiesQuery.get();

    for (final company in companies.docs) {
      final employees = await companiesQuery.doc(company.id).collection(
          'employees').get();
      for (final employee in employees.docs) {
        Query visitsQuery = companiesQuery
            .doc(company.id)
            .collection('employees')
            .doc(employee.id)
            .collection('visits');

        if (dateRange != null) {
          visitsQuery = visitsQuery
              .where('checkInTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start))
              .where('checkInTime',
              isLessThanOrEqualTo: Timestamp.fromDate(dateRange.end));
        }

        total += (await visitsQuery.count().get()).count!.toInt();
      }
    }
    return total;
  }

  Future<int> _getActiveVisits(CollectionReference companiesQuery,
      DateTimeRange? dateRange) async {
    var total = 0;
    final companies = await companiesQuery.get();

    for (final company in companies.docs) {
      final employees = await companiesQuery.doc(company.id).collection(
          'employees').get();
      for (final employee in employees.docs) {
        Query visitsQuery = companiesQuery
            .doc(company.id)
            .collection('employees')
            .doc(employee.id)
            .collection('visits')
            .where('checkOutTime', isNull: true);

        if (dateRange != null) {
          visitsQuery = visitsQuery
              .where('checkInTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start))
              .where('checkInTime',
              isLessThanOrEqualTo: Timestamp.fromDate(dateRange.end));
        }

        total += (await visitsQuery.count().get()).count!.toInt();
      }
    }
    return total;
  }

  Future<List<CompanyVisits>> getCompanyWiseVisits(
      {DateTimeRange? dateRange}) async {
    final companies = await firestore.collection('companies').get();
    final result = <CompanyVisits>[];

    for (final company in companies.docs) {
      var companyVisits = 0;
      final employees = await firestore
          .collection('companies')
          .doc(company.id)
          .collection('employees')
          .get();

      for (final employee in employees.docs) {
        Query<Map<String, dynamic>> visitsQuery = firestore
            .collection('companies')
            .doc(company.id)
            .collection('employees')
            .doc(employee.id)
            .collection('visits');

        if (dateRange != null) {
          visitsQuery = visitsQuery
              .where('checkInTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start))
              .where('checkInTime',
              isLessThanOrEqualTo: Timestamp.fromDate(dateRange.end));
        }

        final visitsCount = (await visitsQuery.count().get()).count;
        companyVisits += visitsCount!;
      }

      result.add(CompanyVisits(
        companyId: company.id,
        companyName: company.data()['name'] ?? 'Unknown',
        visitCount: companyVisits,
      ));
    }

    return result;
  }
}
