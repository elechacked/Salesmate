import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesmate/app/themes/app_images.dart';
import 'package:salesmate/features/company/controller/visits_controller.dart';
import 'package:salesmate/features/company/presentation/visits/widgets/employee_visit_card.dart';

class VisitDashboard extends StatelessWidget {
  final VisitController _controller = Get.put(VisitController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Visit Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.grey[800]),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.grey[800]),
            onPressed: _controller.loadEmployeesWithVisits,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4E79E6)),
            ),
          );
        }

        if (_controller.employeesWithVisits.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppImages.noVisit,
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                Text(
                  'No employees found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Add employees or check your connection',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _controller.loadEmployeesWithVisits,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E79E6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Refresh Data',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF4E79E6),
          onRefresh: () async => _controller.loadEmployeesWithVisits(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _controller.employeesWithVisits.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = _controller.employeesWithVisits[index];
              return EmployeeVisitCard(
                employee: item.employee,
                visitCount: item.totalVisits,
                lastVisit: item.hasVisits ? item.visits.first : null,
                lastVisitDate: item.lastVisitDate,
                onTap: () => Get.toNamed(
                  '/company/visits/employee',
                  arguments: {'employeeEmail': item.employee.email},
                ),
              );
            },
          ),
        );
      }),
    );
  }

}
