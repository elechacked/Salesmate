import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesmate/app/app_routes.dart';
import 'package:salesmate/features/company/controller/employee_controller.dart';
import 'package:salesmate/models/employee_models.dart';

import 'employee_create.dart';

class EmployeeViewScreen extends StatelessWidget {
  final Employee employee;
  final EmployeeController _controller = Get.find();
  final RxBool canEdit = false.obs;

  EmployeeViewScreen({Key? key, required this.employee}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _controller.canAccessEmployee(employee.email),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!) {
          return Scaffold(
            appBar: AppBar(title: const Text('Access Denied')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.block, size: 60, color: Colors.red),
                  const SizedBox(height: 20),
                  Text(
                    'This employee has been deactivated at system level',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  const Text('Please contact your administrator'),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(employee.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => Get.to(
                      () => EmployeeCreateScreen(employee: employee),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildProfileSection(),
                const SizedBox(height: 32),
                _buildDetailsCard(),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),        );
      },
    );
  }




  Widget _buildProfileSection() {
    return Column(
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[200]!, width: 2),
            image: employee.profileImageUrl != null
                ? DecorationImage(
              image: NetworkImage(employee.profileImageUrl!),
              fit: BoxFit.cover,
            )
                : null,
          ),
          child: employee.profileImageUrl == null
              ? Icon(Icons.person, size: 60, color: Colors.grey[400])
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          employee.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          employee.designation ?? 'No designation',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailRow(Icons.email, 'Email', employee.email),
            const Divider(height: 24),
            _buildDetailRow(Icons.phone, 'Phone', employee.phone),
            const Divider(height: 24),
            _buildDetailRow(Icons.work, 'Department', employee.department ?? '-'),
            const Divider(height: 24),
            _buildDetailRow(Icons.badge, 'Designation', employee.designation ?? '-'),
            const Divider(height: 24),
            _buildDetailRow(
              employee.isActive ? Icons.check_circle : Icons.remove_circle,
              'Status',
              employee.isActive ? 'Active' : 'Inactive',
              color: employee.isActive ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.blue[700], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (employee.email.isEmpty) {
                Get.snackbar('Error', 'Invalid employee data');
                return;
              }
              _controller.toggleEmployeeStatus(employee);
              Get.back();
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: employee.isActive ? Colors.red[50] : Colors.green[50],
              foregroundColor: employee.isActive ? Colors.red : Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: employee.isActive ? Colors.red[100]! : Colors.green[100]!,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(employee.isActive ? Icons.person_off : Icons.person_add),
                const SizedBox(width: 8),
                Text(
                  employee.isActive ? 'Deactivate Employee' : 'Activate Employee',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showDeleteDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[100],
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete),
                SizedBox(width: 8),
                Text(
                  'Delete Employee',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _controller.deleteEmployee(employee.email);
              Get.offAllNamed(AppRoutes.companyEmployees);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}