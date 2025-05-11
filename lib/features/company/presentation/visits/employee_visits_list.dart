import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesmate/app/themes/app_images.dart';
import 'package:salesmate/features/export/widgets/export_dialog.dart';
import 'package:salesmate/features/company/controller/visits_controller.dart';
import 'package:salesmate/features/company/presentation/visits/widgets/visit_card.dart';
import 'package:salesmate/features/export/data/export_employee_visit_service.dart';
import 'package:salesmate/features/export/presentation/format_selection_dialog.dart';
import 'package:salesmate/models/export_config.dart';

class EmployeeVisitsList extends StatefulWidget {
  const EmployeeVisitsList({super.key});

  @override
  State<EmployeeVisitsList> createState() => _EmployeeVisitsListState();
}

class _EmployeeVisitsListState extends State<EmployeeVisitsList> {
  final VisitController _controller = Get.find<VisitController>();
  late final String employeeEmail;
  final ExportConfig config = const ExportConfig();
  final ExportEmployeeVisitService _exportService = ExportEmployeeVisitService();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args != null && args['employeeEmail'] != null) {
      employeeEmail = args['employeeEmail'];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.loadEmployeeVisits(employeeEmail);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Obx(() => Text(
          '${_controller.selectedEmployee.value?.name ?? 'Employee'} Visits',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        )),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.grey[800]),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt_rounded, color: Colors.grey[800]),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Visits',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _exportVisits,
        backgroundColor: const Color(0xFF4E79E6),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.upload_rounded, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: Obx(() {
        if (_controller.isLoading.value && _controller.employeeVisits.isEmpty) {
          return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4E79E6)),
              ),
              );
          }

              if (_controller.employeeVisits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AppImages.noVisit, // Replace with your asset
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No Visits Found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This employee has no recorded visits yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF4E79E6),
            onRefresh: () async => _controller.loadEmployeeVisits(employeeEmail),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _controller.employeeVisits.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final visit = _controller.employeeVisits[index];
                return VisitCard(
                  visit: visit,
                  onTap: () => _controller.loadVisitDetails(visit.id).then((_) {
                    Get.toNamed('/company/visits/detail');
                  }),
                );
              },
            ),
          );
        }),
    );
  }

  Future<void> _exportVisits() async {
    final format = await Get.dialog<String>(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: const FormatSelectionDialog(),
      ),
    );
    if (format == null) return;

    final columns = await Get.dialog<List<String>>(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: ExportDialog(
          format: format,
          selectedColumns: config.defaultVisitColumns,
          onColumnsChanged: (cols) {},
          isEmployee: false,
        ),
      ),
    );
    if (columns == null) return;

    await _exportService.exportEmployeeVisits(
      format: format,
      selectedColumns: columns,
      singleEmployee: true,
    );
  }

  void _showFilterDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Visits',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => SwitchListTile(
                title: const Text('Show only ongoing visits'),
                value: _controller.filterOngoing.value,
                onChanged: (val) {
                  _controller.filterOngoing.value = val;
                },
                activeColor: const Color(0xFF4E79E6),
              )),
              const SizedBox(height: 16),
              Obx(
                    () => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4E79E6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFF4E79E6)),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () async {
                    final range = await showDateRangePicker(
                      context: Get.context!,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (range != null) {
                      _controller.dateRange.value = range;
                    }
                  },
                  child: Text(
                    _controller.dateRange.value == null
                        ? 'Select Date Range'
                        : '${_controller.formatDate(_controller.dateRange.value!.start)} - '
                        '${_controller.formatDate(_controller.dateRange.value!.end)}',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[800],
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        _controller.clearFilters();
                        Get.back();
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4E79E6),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        _controller.applyFilters();
                        Get.back();
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}