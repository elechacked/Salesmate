import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesmate/app/themes/app_images.dart';
import 'package:salesmate/features/company/controller/profile_controller.dart';

class CompanyProfileScreen extends StatelessWidget {
  final CompanyProfileController controller = Get.put(CompanyProfileController());

  CompanyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _buildBody(context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Company Profile',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      actions: [
        Obx(() {
          if (controller.hasChanges.value) {
            return TextButton(
              onPressed: controller.saveProfile,
              child: const Text(
                'SAVE',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator.adaptive(
            backgroundColor: Colors.white,
          ),
        );
      }

      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // Logo Section
            _buildLogoSection(),
            const SizedBox(height: 32),

            // Editable Fields
            _buildEditableFields(),
            const SizedBox(height: 24),

            // Read-only Fields
            _buildReadOnlyFields(),
            const SizedBox(height: 24),

            // Save Button (only shows when there are changes)
            Obx(() {
              if (controller.hasChanges.value) {
                return _buildSaveButton(context);
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      );
    });
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Obx(() {
              final logo = controller.logoUrl.value;
              return Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: logo.isNotEmpty
                      ? Image.network(
                    logo,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.business, size: 40),
                  )
                      : _buildDefaultLogo(),
                ),
              );
            }),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: controller.updateLogo,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.blue.withOpacity(0.4),
                          blurRadius: 6,
                          spreadRadius: 2)
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Tap to change logo',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Icon(
          Icons.business,
          size: 50,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildEditableFields() {
    return Column(
      children: [
        _buildCustomTextField(
          textcontroller: controller.nameController,
          label: 'Company Name',
          icon: Icons.business_outlined,
        ),
        const SizedBox(height: 16),
        _buildCustomTextField(
          textcontroller: controller.natureOfBusinessController,
          label: 'Nature of Business',
          icon: Icons.category_outlined,
        ),
        const SizedBox(height: 16),
        _buildCustomTextField(
          textcontroller: controller.gstNumberController,
          label: 'GST Number',
          icon: Icons.numbers_outlined,
        ),
        const SizedBox(height: 16),
        _buildCustomTextField(
          textcontroller: controller.addressController,
          label: 'Address',
          icon: Icons.location_on_outlined,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        _buildCustomTextField(
          textcontroller: controller.websiteController,
          label: 'Website',
          icon: Icons.link_outlined,
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }

  Widget _buildCustomTextField({

    required TextEditingController textcontroller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: textcontroller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(icon, size: 20, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
      onChanged: (value) => controller.hasChanges, // Updated this line
    );
  }

  Widget _buildReadOnlyFields() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildReadOnlyItem(
            icon: Icons.email_outlined,
            title: 'Owner Email',
            value: controller.ownerEmailController.text,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildReadOnlyItem(
            title: 'Contact Number',
            icon: Icons.phone_outlined,
            value: controller.contactNumberController.text,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildReadOnlyItem(
            icon: Icons.people_outline,
            title: 'Max Employees',
            value: controller.maxUsersController.text,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildReadOnlyItem(
            icon: Icons.calendar_today_outlined,
            title: 'Subscription Expiry',
            value: controller.subscriptionExpiry.value,
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
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

  Widget _buildSaveButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: controller.saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shadowColor: Colors.blue.withOpacity(0.3),
          ),
          child: const Text(
            'SAVE CHANGES',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}