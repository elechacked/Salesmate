import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesmate/app/app_routes.dart';
import 'package:salesmate/features/export/widgets/export_dialog.dart';
import 'package:salesmate/features/export/data/Employe_export_services.dart';
import 'package:salesmate/features/employee/controller/employee_home_controller.dart';
import 'package:salesmate/features/employee/presentation/employee_completed_visit_card.dart';
import 'package:salesmate/features/employee/presentation/employee_ongoing_visit_card.dart';
import 'package:salesmate/features/export/presentation/format_selection_dialog.dart';
import 'package:salesmate/features/export/presentation/visit_selection_dialog.dart';
import 'package:salesmate/models/export_config.dart';
import 'package:salesmate/models/visit_models.dart';

class EmployeeHomeScreen extends StatelessWidget {
  const EmployeeHomeScreen({super.key});

  void _handleExport(BuildContext context) async {
    final controller = Get.find<EmployeeHomeController>();
    if (controller.completedVisits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No visits to export')),
      );
      return;
    }

    // 1. Show visit selection dialog
    final selectedVisits = await showDialog<List<Visit>>(
      context: context,
      builder: (_) => VisitSelectionDialog(
        visits: controller.completedVisits,
      ),
    );

    if (selectedVisits == null || selectedVisits.isEmpty) return;

    // 2. Show format selection
    final format = await showDialog<String>(
      context: context,
      builder: (_) => const FormatSelectionDialog(),
    );

    if (format == null) return;

    // 3. Show export options
    final columns = await showDialog<List<String>>(
      context: context,
      builder: (_) => ExportDialog(
        format: format,
        selectedColumns: ExportConfig().defaultVisitColumns,
        onColumnsChanged: (cols) {},
      ),
    );

    if (columns == null) return;

    // 4. Export and share
    debugPrint('Selected columns: $columns');
    debugPrint('Visits to export: ');

    try {
      await EmployeeExportService.exportVisits(
        visits: selectedVisits,
        format: format,
        columns: columns,
        context: context,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export completed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EmployeeHomeController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Visits'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Get.toNamed(AppRoutes.employeeProfile),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.refreshVisits();
        },
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Ongoing Visit Section (25% of screen)
              Container(
                height: MediaQuery.of(context).size.height * 0.25,
                padding: const EdgeInsets.only(top: 16),
                child: _buildOngoingVisitSection(controller),
              ),

              // Completed Visits Section (75% of screen)
              Expanded(
                child: _buildCompletedVisitsSection(controller),
              ),
            ],
          );
        }),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'export_button',
              onPressed: () => _handleExport(context),
              child: const Icon(Icons.upload),
              tooltip: 'Export Visits',
              backgroundColor: Colors.blue,
            ),
            const Spacer(),
            if (controller.ongoingVisits.isEmpty)
              FloatingActionButton.extended(
                heroTag: 'new_visit_button',
                onPressed: () async {
                  final result = await Get.toNamed(AppRoutes.employeeCheckin);
                  if (result == true) {
                    controller.refreshVisits();
                  }
                },
                label: const Text('New Visit'),
                icon: const Icon(Icons.add),
                backgroundColor: Colors.green,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOngoingVisitSection(EmployeeHomeController controller) {
    if (controller.ongoingVisits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'No ongoing visit',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: controller.ongoingVisits.length,
      itemBuilder: (context, index) => EmployeeOngoingVisitCard(
        visit: controller.ongoingVisits[index],
      ),
    );
  }

  Widget _buildCompletedVisitsSection(EmployeeHomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 16, 8),
          child: Text(
            'Visit History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: controller.completedVisits.isEmpty
              ? Center(
            child: Text(
              'No completed visits yet',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          )
              : ListView.builder(
            itemCount: controller.completedVisits.length,
            itemBuilder: (context, index) => EmployeeCompletedVisitCard(
              visit: controller.completedVisits[index],
              serialNumber: index + 1,
            ),
          ),
        ),
      ],
    );
  }
}