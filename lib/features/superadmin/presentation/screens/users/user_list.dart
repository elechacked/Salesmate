import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesmate/features/superadmin/controllers/user_controller.dart';
import 'package:salesmate/app/themes/app_text_styles.dart';
import 'package:salesmate/features/superadmin/presentation/screens/users/user_create_screen.dart';
import 'package:salesmate/features/superadmin/presentation/screens/users/user_details.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('User Management', style: AppTextStyles.heading),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchUsers,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const CreateUserScreen()),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchUsers,
        child: Obx(() {
          if (controller.isLoading.value && controller.users.isEmpty) {
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
                    onPressed: controller.fetchUsers,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (controller.users.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.users.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final user = controller.users[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(user.email, style: AppTextStyles.subheading),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (user.name != null) Text('Name: ${user.name!}'),
                      Text('Role: ${user.role.toUpperCase()}'),
                      if (user.companyId != null) Text('Company: ${user.companyId}'),
                      Text(
                        'Status: ${user.isActive ? 'Active' : 'Inactive'}',
                        style: TextStyle(
                          color: user.isActive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Get.to(
                        () => UserDetailsScreen(userEmail: user.email),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}