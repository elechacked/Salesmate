import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesmate/app/app_routes.dart';
import 'package:salesmate/app/themes/app_colors.dart';
import 'package:salesmate/app/themes/app_text_styles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:salesmate/features/auth/controller/auth_controller.dart';
import 'package:salesmate/features/superadmin/controllers/analytics_controller.dart';
import 'package:salesmate/features/superadmin/controllers/superadmin_controller.dart';
import 'package:salesmate/features/superadmin/presentation/screens/users/user_list.dart';

class SuperadminDashboard extends StatefulWidget {
  const SuperadminDashboard({super.key});

  @override
  State<SuperadminDashboard> createState() => _SuperadminDashboardState();
}

class _SuperadminDashboardState extends State<SuperadminDashboard> {

  late final AnalyticsController analyticsController;
  late final SuperadminController superadminController;

  @override
  void initState() {
    super.initState();
    analyticsController = Get.put(AnalyticsController(getAnalytics: Get.find()));
    superadminController = Get.put(SuperadminController(getCompanies: Get.find()));

    // Fetch data immediately
    analyticsController.fetchAnalytics();
    superadminController.fetchCompanies();
  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Superadmin Dashboard', style: AppTextStyles.heading),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
              Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
              Tab(icon: Icon(Icons.business), text: 'Companies'),
              Tab(icon: Icon(Icons.people), text: 'Users'),
              // Tab(icon: Icon(Icons.payment_rounded), text: 'Subscriptions',)// New tab
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                analyticsController.fetchAnalytics();
                superadminController.fetchCompanies();
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                Get.back();
                await Get.find<AuthController>().logout();
                Get.offAllNamed(AppRoutes.login);
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(analyticsController),
            _buildAnalyticsTab(analyticsController),
            _buildCompaniesTab(superadminController),
            _buildUsersTab(superadminController),
            // New tab content

          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(AnalyticsController controller) {
    return Obx(() {
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDateRangeSelector(controller),
            const SizedBox(height: 20),
            _buildStatCard('Total Companies', analytics.totalCompanies.toString()),
            _buildStatCard('Active Companies', analytics.activeCompanies.toString()),
            _buildStatCard('Total Employees', analytics.totalEmployees.toString()),
            _buildStatCard('Total Visits', analytics.totalVisits.toString()),
            _buildStatCard('Active Visits', analytics.activeVisits.toString()),
            _buildStatCard('Avg Visits/Company', analytics.averageVisitsPerCompany.toStringAsFixed(1)),
            _buildStatCard('Avg Visits/Employee', analytics.averageVisitsPerEmployee.toStringAsFixed(1)),
          ],
        ),
      );
    });
  }

  Widget _buildAnalyticsTab(AnalyticsController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final analytics = controller.analytics.value;
      final companyVisits = controller.companyVisits;

      if (analytics == null || companyVisits.isEmpty) {
        return const Center(child: Text('No analytics data available'));
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDateRangeSelector(controller),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: companyVisits.map((e) => e.visitCount.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2,
                  barGroups: companyVisits
                      .map((e) => BarChartGroupData(
                    x: companyVisits.indexOf(e),
                    barRods: [
                      BarChartRodData(
                        toY: e.visitCount.toDouble(),
                        color: AppColors.primaryColor,
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
                        reservedSize: 40, // Add reserved space for titles
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < companyVisits.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                companyVisits[index].companyName,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black54,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    // Other axis titles
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                  ),                ),
              ),
            ),
            const SizedBox(height: 20),
            ...companyVisits.map((e) => ListTile(
              title: Text(e.companyName),
              trailing: Text(e.visitCount.toString()),
            )).toList(),
          ],
        ),
      );
    });
  }

  Widget _buildCompaniesTab(SuperadminController controller) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search Companies',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onChanged: controller.filterCompanies,
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return Center(child: Text(controller.errorMessage.value));
                }

                if (controller.companies.isEmpty) {
                  return const Center(child: Text('No companies found'));
                }

                return ListView.builder(
                  itemCount: controller.companies.length,
                  itemBuilder: (context, index) {
                    final company = controller.companies[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: ListTile(
                        title: Text(company.name, style: AppTextStyles.subheading),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(company.ownerEmail),
                            Text('Max Users: ${company.maxUsers}'),
                            Text('Expiry: ${company.subscriptionExpiry.toLocal().toString().split(' ')[0]}'),
                            Text('Status: ${company.isActive ? 'Active' : 'Suspended'}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () => Get.toNamed(
                            '/superadmin/companies/detail',
                            arguments: company.id,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
              Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton(
                  onPressed: () => Get.toNamed('/superadmin/companies/create'),
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildStatCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.body.copyWith(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.heading),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab(SuperadminController controller) {
    return const UserListScreen(); // GetX will automatically find the controller
  }
}