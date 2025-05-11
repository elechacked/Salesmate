import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:salesmate/features/employee/controller/employee_checkout_controller.dart';
import 'package:salesmate/models/visit_models.dart';

class EmployeeCheckoutScreen extends StatelessWidget {
  final Visit visit;

  const EmployeeCheckoutScreen({super.key, required this.visit});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EmployeeCheckoutController(visit: visit));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Out'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context,),
            const SizedBox(height: 24),

            // Visiting Company Name (Uneditable)
            _buildReadOnlyField(
              label: 'Visiting Company',
              value: visit.visitingCompanyName,
              icon: Icons.business,
            ),
            const SizedBox(height: 20),

            // Check-in Time (Uneditable)
            _buildReadOnlyField(
              label: 'Check-in Time',
              value: DateFormat('MMM dd, yyyy - hh:mm a').format(visit.checkInTime),
              icon: Icons.access_time,
            ),
            const SizedBox(height: 20),

            // Visit Purpose (Uneditable)
            _buildReadOnlyField(
              label: 'Visit Purpose',
              value: visit.visitPurpose ?? 'Not specified',
              icon: Icons.assignment,
            ),
            const SizedBox(height: 20),

            // Check-out Time (Indian Time)
            Obx(() => _buildReadOnlyField(
              label: 'Check-out Time',
              value: DateFormat('MMM dd, yyyy - hh:mm a').format(controller.currentTime.value),
              icon: Icons.logout,
            )),
            const SizedBox(height: 20),

            // Contact Person Name
            _buildTextField(
              controller: controller.contactNameController,
              label: 'Contact Person Name*',
              hint: 'Name of person you met',
              icon: Icons.person,
            ),
            const SizedBox(height: 20),

            // Contact Number
            _buildTextField(
              controller: controller.contactPhoneController,
              label: 'Contact Number*',
              hint: 'Phone number of contact',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            // Outcome
            _buildDropdownField(
              label: 'Outcome*',
              value: controller.selectedOutcome.value,
              items: const [
                'Successful',
                'Rescheduled',
                'Cancelled',
                'Partially Successful',
                'Follow-up Needed'
              ],
              onChanged: (value) => controller.selectedOutcome.value = value!,
              icon: Icons.outbound,
            ),
            const SizedBox(height: 20),

            // Remarks
            _buildTextField(
              controller: controller.remarksController,
              label: 'Remarks',
              hint: 'Additional notes about the visit',
              icon: Icons.note,
              maxLines: 3,
            ),

            const SizedBox(height: 30),

            _buildTextField(
                controller: controller.addressController,
                label: 'Address',
                hint: 'Address Of the Company',
                icon: Icons.location_on_outlined),

            const SizedBox(height: 30),


            // Checkout Button
            Obx(() => _buildCheckoutButton(controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Complete Visit',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please fill in the details below to complete your visit',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButtonFormField<String>(
              value: value,
              icon: const Icon(Icons.arrow_drop_down),
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: Colors.grey[600]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: onChanged,
              isExpanded: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton(EmployeeCheckoutController controller) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.submitCheckout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: controller.isLoading.value
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 20),
            SizedBox(width: 8),
            Text(
              'COMPLETE CHECKOUT',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}