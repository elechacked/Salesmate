import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesmate/features/superadmin/domain/entities/analytics_entity.dart';
import 'package:salesmate/features/superadmin/domain/usecases/get_analytics.dart';

class AnalyticsController extends GetxController {
  final GetAnalytics getAnalytics;

  AnalyticsController({required this.getAnalytics});

  final Rx<AnalyticsEntity?> analytics = Rx<AnalyticsEntity?>(null);
  final RxList<CompanyVisits> companyVisits = <CompanyVisits>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<DateTimeRange?> dateRange = Rx<DateTimeRange?>(null);



  Future<void> fetchAnalytics() async {
    isLoading.value = true;
    try {
      final analyticsData = await getAnalytics(dateRange: dateRange.value);
      analytics.value = analyticsData;

      final companyVisitsData = await getAnalytics.getCompanyWiseVisits(dateRange: dateRange.value);
      companyVisits.assignAll(companyVisitsData);
    } finally {
      isLoading.value = false;
    }
  }

  void setDateRange(DateTimeRange range) {
    dateRange.value = range;
    fetchAnalytics();
  }

  void resetDateRange() {
    dateRange.value = null;
    fetchAnalytics();
  }
}