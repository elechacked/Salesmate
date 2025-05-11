import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesmate/app/themes/app_text_styles.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:salesmate/features/superadmin/controllers/analytics_controller.dart';
import 'package:salesmate/features/superadmin/domain/entities/analytics_entity.dart';

class UsageAnalyticsScreen extends StatelessWidget {
  const UsageAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AnalyticsController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Usage Analytics', style: AppTextStyles.heading),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchAnalytics,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final analytics = controller.analytics.value;
        if (analytics == null) {
          return const Center(child: Text('No analytics data available'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildDateRangeSelector(controller),
              const SizedBox(height: 20),
              _buildStatsGrid(analytics),
              const SizedBox(height: 20),
              _buildCompaniesChart(controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDateRangeSelector(AnalyticsController controller) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              final now = DateTime.now();
              final initialRange = DateTimeRange(
                start: now.subtract(const Duration(days: 30)),
                end: now,
              );
              final pickedRange = await showDateRangePicker(
                context: Get.context!,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                initialDateRange: initialRange,
              );
              if (pickedRange != null) {
                controller.setDateRange(pickedRange);
              }
            },
            child: Obx(() {
              if (controller.dateRange.value == null) {
                return const Text('Select Date Range');
              }
              final range = controller.dateRange.value!;
              return Text(
                '${range.start.toLocal().toString().split(' ')[0]} - ${range.end.toLocal().toString().split(' ')[0]}',
              );
            }),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: controller.resetDateRange,
        ),
      ],
    );
  }

  Widget _buildStatsGrid(AnalyticsEntity analytics) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total Companies', analytics.totalCompanies.toString()),
        _buildStatCard('Active Companies', analytics.activeCompanies.toString()),
        _buildStatCard('Total Employees', analytics.totalEmployees.toString()),
        _buildStatCard('Total Visits', analytics.totalVisits.toString()),
        _buildStatCard('Active Visits', analytics.activeVisits.toString()),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: AppTextStyles.body.copyWith(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.heading),
          ],
        ),
      ),
    );
  }

  Widget _buildCompaniesChart(AnalyticsController controller) {
    return Obx(() {
      if (controller.companyVisits.isEmpty) {
        return const SizedBox();
      }

      return SizedBox(
        height: 300,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: controller.companyVisits
                .map((e) => e.visitCount.toDouble())
                .reduce((a, b) => a > b ? a : b) * 1.2,
            barGroups: controller.companyVisits
                .map((e) => BarChartGroupData(
              x: controller.companyVisits.indexOf(e),
              barRods: [
                BarChartRodData(
                  toY: e.visitCount.toDouble(),
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ))
                .toList(),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < controller.companyVisits.length) {
                      return Transform.rotate(
                        angle: -0.4, // Optional: Rotate text for better fit
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            controller.companyVisits[index].companyName,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              // Configure other axes as needed
            ),
          ),
        ),
      );
    });
  }
}