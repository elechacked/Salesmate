import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesmate/features/superadmin/controllers/super_company_controller.dart';
import 'package:salesmate/app/themes/app_text_styles.dart';

class CompanyListScreen extends StatelessWidget {
  const CompanyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SuperCompanyController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Companies', style: AppTextStyles.heading),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchCompanies,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/superadmin/companies/create'),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage));
        }

        if (controller.companies.isEmpty) {
          return const Center(child: Text('No companies found'));
        }

        return ListView.builder(
          itemCount: controller.companies.length,
          itemBuilder: (context, index) {
            final company = controller.companies[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ListTile(
                title: Text(company.name, style: AppTextStyles.subheading),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(company.ownerEmail),
                    Text('Max Users: ${company.maxUsers}'),
                    Text('Status: ${company.isActive ? 'Active' : 'Suspended'}'),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => Get.toNamed(
                  '/superadmin/companies/detail',
                  arguments: company.id,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
