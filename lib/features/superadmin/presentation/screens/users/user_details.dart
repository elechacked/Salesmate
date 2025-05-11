import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesmate/app/themes/app_text_styles.dart';
import 'package:salesmate/app/themes/app_colors.dart';
import 'package:salesmate/features/superadmin/controllers/user_controller.dart';
import 'package:salesmate/features/superadmin/domain/entities/user_entity.dart';

class UserDetailsScreen extends StatelessWidget {
  final String userEmail;

  const UserDetailsScreen({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.currentUser.value?.email != userEmail) {
        controller.getUserDetails(userEmail);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('User Details', style: AppTextStyles.heading),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.currentUser.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${controller.errorMessage.value}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    controller.errorMessage.value = '';
                    controller.getUserDetails(userEmail);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final user = controller.users.firstWhereOrNull((u) => u.email == userEmail) ??
            controller.currentUser.value;

        if (user == null || user.email != userEmail) {
          return const Center(child: Text('User data not available'));
        }

        return _buildUserDetails(user, controller);
      }),
    );
  }

  Widget _buildUserDetails(UserEntity user, UserController controller) {
    final isSuperadmin = user.role == 'superadmin';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user.name != null) _buildDetailItem('Name', user.name!),
          _buildDetailItem('Email', user.email),
          if (user.phone != null) _buildDetailItem('Phone', user.phone!),
          _buildDetailItem('Role', user.role.toUpperCase()),
          if (user.companyId != null) _buildDetailItem('Company ID', user.companyId!),
          _buildStatusItem(user.isActive),
          _buildDetailItem(
            'Created At',
            '${user.createdAt.toLocal().toString().split(' ')[0]}\n'
                '${user.createdAt.toLocal().toString().split(' ')[1].substring(0, 5)}',
          ),

          if (!isSuperadmin) ...[
            const SizedBox(height: 20),
            _buildToggleButton(user, controller),
          ],
        ],
      ),
    );
  }





  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.body.copyWith(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.body),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildStatusItem(bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status', style: AppTextStyles.body.copyWith(color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isActive ? 'Active' : 'Inactive',
              style: AppTextStyles.body.copyWith(
                color: isActive ? Colors.green[800] : Colors.red[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildToggleButton(UserEntity user, UserController controller) {
    return Obx(() {
      final isProcessing = controller.isLoading.value &&
          controller.currentUser.value?.email == user.email;

      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: user.isActive ? AppColors.errorColor : AppColors.success,
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: isProcessing ? null : () => _onTogglePressed(user, controller),
        child: isProcessing
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
          user.isActive ? 'Deactivate User' : 'Activate User',
          style: AppTextStyles.buttonText.copyWith(color: Colors.white),
        ),
      );
    });
  }

  Future<void> _onTogglePressed(UserEntity user, UserController controller) async {
    try {
      await controller.toggleUserStatus(user.email, user.isActive);
      Get.snackbar(
        'Success',
        'User status updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update status: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

}