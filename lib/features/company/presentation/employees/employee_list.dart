import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';

import 'package:salesmate/app/app_routes.dart';
import 'package:salesmate/core/utils/permission_utils.dart';

import 'package:salesmate/features/company/controller/employee_controller.dart';
import 'package:salesmate/features/export/data/company_employee_export_service.dart';
import 'package:salesmate/models/employee_models.dart';
import 'employee_create.dart';
import 'employee_view.dart';

class EmployeeListScreen extends StatelessWidget {
  final EmployeeController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Members'),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.toNamed(AppRoutes.companyDashboard),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _controller.loadEmployees,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => EmployeeCreateScreen()),
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue[700],
      ),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return _controller.employees.isEmpty
                  ? _buildEmptyState()
                  : _buildEmployeeList();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Team Members',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
      Obx(() {
        return Text(
          '${_controller.employees.length} of ${_controller.maxUsers.value} slots used',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        );
      }),
              ],
            ),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.upload, size: 20),
            ),
            onPressed: () => _showExportOptions(context),
            tooltip: 'Export',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_alt, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'No Team Members',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first team member to get started',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _controller.employees.length,
      itemBuilder: (context, index) {
        final employee = _controller.employees[index];
        return _EmployeeCard(employee: employee);
      },
    );
  }

  Future<void> _handleExport(BuildContext context) async {
    if (_controller.employees.isEmpty) {
      Get.snackbar('Error', 'No employees to export');
      return;
    }

    try {
      await CompanyEmployeeExportService.exportEmployees(
        employees: _controller.employees,
        format: 'Excel',
        columns: ['Name', 'Email', 'Phone', 'Department', 'Designation', 'Status'],
        context: context,
      );
      Get.snackbar('Success', 'Export completed successfully'); // Fixed from 'Error' to 'Success'
    } catch (e) {
      Get.snackbar('Error', 'Export failed: ${e.toString()}');
    }
  }

  Future<void> _showExportOptions(BuildContext context) async {
    if (_controller.employees.isEmpty) {
      Get.snackbar('Error' ,'No employees to export');
      return;
    }

    // Step 1: Select employees
    final selectedIndices = List<bool>.filled(
        _controller.employees.length, true);
    final selectedEmployees = await Get.dialog<List<Employee>>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Select Employees to Export',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                const Divider(height: 1),
                CheckboxListTile(
                  title: const Text('Select All'),
                  value: selectedIndices.every((element) => element),
                  onChanged: (value) {
                    setState(() {
                      for (var i = 0; i < selectedIndices.length; i++) {
                        selectedIndices[i] = value!;
                      }
                    });
                  },
                ),
                const Divider(height: 1),
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: _controller.employees.length,
                    itemBuilder: (context, index) {
                      final employee = _controller.employees[index];
                      return CheckboxListTile(
                        title: Text(employee.name),
                        subtitle: Text(employee.department ?? 'No department'),
                        value: selectedIndices[index],
                        onChanged: (value) {
                          setState(() {
                            selectedIndices[index] = value!;
                          });
                        },
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final selected = <Employee>[];
                          for (var i = 0; i <
                              _controller.employees.length; i++) {
                            if (selectedIndices[i]) {
                              selected.add(_controller.employees[i]);
                            }
                          }
                          Get.back(result: selected);
                        },
                        child: const Text('Export'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );

    if (selectedEmployees == null || selectedEmployees.isEmpty) return;

    // Step 2: Select format
    final format = await Get.dialog<String>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Export Format',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const Divider(height: 1),
            Column(
              children: [
                ListTile(
                  title: const Text('Excel'),
                  leading: const Icon(Icons.table_chart),
                  onTap: () => Get.back(result: 'Excel'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('CSV'),
                  leading: const Icon(Icons.grid_on),
                  onTap: () => Get.back(result: 'CSV'),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (format == null) return;

    // Export and share/save

    try {
      // Create export directory if it doesn't exist
      final dir = await getTemporaryDirectory();
      final exportDir = Directory('${dir.path}/exports');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      final filePath = '${exportDir.path}/employees_export.${format
          .toLowerCase()}';
      final file = File(filePath);
      final columns = ['Name', 'Email', 'Phone', 'Department', 'Designation', 'Status'];


      if (format == 'Excel') {
        await CompanyEmployeeExportService.exportToExcel(selectedEmployees, columns , file);
      } else if (format == 'CSV') {
        await CompanyEmployeeExportService.exportToCSV(selectedEmployees, columns ,file);
      }

      // Show save/share options
      await showModalBottomSheet(
        context: context,
        builder: (context) => _buildExportOptionsBottomSheet(file, format),
      );
    } catch (e) {
      Get.snackbar('Error' ,'Export failed: ${e.toString()}');
    }
  }


  // Show options to share or save
  Widget _buildExportOptionsBottomSheet(File file, String format) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share File'),
            onTap: () async {
              Get.back();
              await Share.shareXFiles([XFile(file.path)]);
            },
          ),
          ListTile(
            leading: const Icon(Icons.save_alt),
            title: const Text('Save to Device'),
            onTap: () async {
              Get.back();
              await _saveFileToDownloads(file, format);
            },
          ),
        ],
      ),
    );
  }


  Future<void> _saveFileToDownloads(File file, String format) async {
    try {
      if (!await PermissionUtils.requestStoragePermission()) {
        Get.snackbar('Error', 'Storage permission required');
        return;
      }

      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir == null) {
        throw Exception('Could not access downloads directory');
      }

      final fileName = 'employees_${DateTime.now().millisecondsSinceEpoch}.${format.toLowerCase()}';
      final savedPath = '${downloadsDir.path}/$fileName';

      await file.copy(savedPath);
      Get.snackbar('Success', 'File saved to Downloads folder'); // Fixed from 'Error' to 'Success'
    } catch (e) {
      Get.snackbar('Error', 'Failed to save file: ${e.toString()}');
    }
  }

}



class _EmployeeCard extends StatelessWidget {
  final Employee employee;
  final EmployeeController _controller = Get.find();


  _EmployeeCard({required this.employee});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _controller.canAccessEmployee(employee.email),
      builder: (context, snapshot) {
        final canAccess = snapshot.data ?? false;
        final cardColor = canAccess ? Colors.white : Colors.grey[100];

        return Opacity(
          opacity: canAccess ? 1.0 : 0.6,
          child: Card(
            color: cardColor,
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () async {
                if (!canAccess) {
                  Get.snackbar('Error' ,
                      'This employee is deactivated at system level and cannot be accessed'
                  );
                  return;
                }
                Get.to(() => EmployeeViewScreen(employee: employee));
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                        image: employee.profileImageUrl != null
                            ? DecorationImage(
                          image: NetworkImage(employee.profileImageUrl!),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: employee.profileImageUrl == null
                          ? Icon(Icons.person, color: Colors.grey[600])
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employee.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            employee.designation ?? 'No designation',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: canAccess
                            ? (employee.isActive ? Colors.green[50] : Colors
                            .red[50])
                            : Colors.grey[200],
                        border: Border.all(
                          color: canAccess
                              ? (employee.isActive ? Colors.green[100]! : Colors
                              .red[100]!)
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        canAccess
                            ? (employee.isActive ? 'Active' : 'Inactive')
                            : 'System Inactive',
                        style: TextStyle(
                          color: canAccess
                              ? (employee.isActive ? Colors.green[800] : Colors
                              .red[800])
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}