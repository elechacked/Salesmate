import 'package:flutter/material.dart';
import 'package:salesmate/features/superadmin/data/repositories/analytics_repository.dart';
import 'package:salesmate/features/superadmin/domain/entities/analytics_entity.dart';

class GetAnalytics {
  final AnalyticsRepository repository;

  GetAnalytics(this.repository);

  Future<AnalyticsEntity> call({DateTimeRange? dateRange}) =>
      repository.getPlatformAnalytics(dateRange: dateRange);
  Future<List<CompanyVisits>> getCompanyWiseVisits({DateTimeRange? dateRange}) =>
      repository.getCompanyWiseVisits(dateRange: dateRange);
}