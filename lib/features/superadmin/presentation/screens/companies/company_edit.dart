import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesmate/features/superadmin/controllers/super_company_controller.dart';
import 'package:salesmate/app/themes/app_colors.dart';
import 'package:salesmate/app/themes/app_text_styles.dart';
import 'package:salesmate/features/superadmin/domain/entities/company_entity.dart';

class CompanyEditScreen extends StatefulWidget {
  const CompanyEditScreen({super.key});

  @override
  State<CompanyEditScreen> createState() => _CompanyEditScreenState();
}

class _CompanyEditScreenState extends State<CompanyEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<SuperCompanyController>();

  late TextEditingController _nameController;
  late TextEditingController _ownerEmailController;
  late TextEditingController _maxUsersController;
  late TextEditingController _gstController;
  late TextEditingController _natureController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;
  late TextEditingController _websiteController;

  late DateTime _expiryDate;
  late bool _isActive;
  late String _companyId;

  @override
  void initState() {
    super.initState();
    final company = _controller.currentCompany;
    _companyId = company!.id;
    _nameController = TextEditingController(text: company.name);
    _ownerEmailController = TextEditingController(text: company.ownerEmail);
    _maxUsersController = TextEditingController(text: company.maxUsers.toString());
    _gstController = TextEditingController(text: company.gstNumber ?? '');
    _natureController = TextEditingController(text: company.natureOfBusiness ?? '');
    _contactController = TextEditingController(text: company.contactNumber ?? '');
    _addressController = TextEditingController(text: company.address ?? '');
    _websiteController = TextEditingController(text: company.website ?? '');
    _expiryDate = company.subscriptionExpiry;
    _isActive = company.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ownerEmailController.dispose();
    _maxUsersController.dispose();
    _gstController.dispose();
    _natureController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Company', style: AppTextStyles.heading),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Company Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter company name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ownerEmailController,
                decoration: const InputDecoration(labelText: 'Owner Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter owner email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _maxUsersController,
                decoration: const InputDecoration(labelText: 'Max Users'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter max users';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              ListTile(
                title: Text(
                  'Subscription Expiry: ${_expiryDate.toLocal().toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _expiryDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _expiryDate = pickedDate;
                    });
                  }
                },
              ),
              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              TextFormField(
                controller: _gstController,
                decoration: const InputDecoration(labelText: 'GST Number (optional)'),
              ),
              TextFormField(
                controller: _natureController,
                decoration: const InputDecoration(labelText: 'Nature of Business (optional)'),
              ),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact Number (optional)'),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address (optional)'),
                maxLines: 2,
              ),
              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(labelText: 'Website (optional)'),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _submitForm,
                      child: Text(
                        'Update Company',
                        style: AppTextStyles.buttonText,
                      ),
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final company = CompanyEntity(
        id: _companyId,
        name: _nameController.text,
        ownerEmail: _ownerEmailController.text,
        maxUsers: int.parse(_maxUsersController.text),
        subscriptionExpiry: _expiryDate,
        isActive: _isActive,
        createdAt: _controller.currentCompany!.createdAt,
        gstNumber: _gstController.text.isEmpty ? null : _gstController.text,
        natureOfBusiness: _natureController.text.isEmpty ? null : _natureController.text,
        contactNumber: _contactController.text.isEmpty ? null : _contactController.text,
        address: _addressController.text.isEmpty ? null : _addressController.text,
        website: _websiteController.text.isEmpty ? null : _websiteController.text,
      );

      _controller.updateCompany(company);
    }
  }

  void _confirmDelete() {
    Get.defaultDialog(
      title: 'Delete Company',
      middleText: 'Are you sure you want to delete this company? This action cannot be undone.',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () {
        _controller.deleteCompany(_companyId);
        Get.back();
      },
    );
  }
}