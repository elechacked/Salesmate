import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesmate/features/company/controller/employee_controller.dart';
import 'package:salesmate/models/employee_models.dart';

import '../../../../core/services/auth_service.dart';

class EmployeeCreateScreen extends StatefulWidget {
  final Employee? employee;
  final bool canEdit;

  const EmployeeCreateScreen({
    Key? key,
    this.employee,
    this.canEdit = true,
  }) : super(key: key);

  @override
  _EmployeeCreateScreenState createState() => _EmployeeCreateScreenState();
}

class _EmployeeCreateScreenState extends State<EmployeeCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final EmployeeController _controller = Get.find();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _departmentController = TextEditingController();
  final _designationController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _nameController.text = widget.employee!.name;
      _phoneController.text = widget.employee!.phone.substring(3);
      _emailController.text = widget.employee!.email;
      _departmentController.text = widget.employee!.department ?? '';
      _designationController.text = widget.employee!.designation ?? '';
    }
    else {
      _phoneController.addListener(() {
        final phone = _phoneController.text.trim();
        if (phone.length == 10) {
          _emailController.text = '+91$phone@pska.org.in';
        } else {
          _emailController.text = '';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employee == null ? 'Add Team Member' : 'Edit Team Member'),
        elevation: 0,
        centerTitle: true,
        actions: [
          if (widget.employee != null && !widget.canEdit)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                Get.snackbar(
                  'Information',
                  'This employee is currently deactivated and cannot be edited',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSection(),
              const SizedBox(height: 32),
              _buildNameField(),
              const SizedBox(height: 16),
              _buildPhoneField(),
              const SizedBox(height: 16),
              _buildEmailField(),
              if (widget.employee == null) ...[
                const SizedBox(height: 16),
                _buildPasswordField(),
              ],
              const SizedBox(height: 16),
              _buildDepartmentField(),
              const SizedBox(height: 16),
              _buildDesignationField(),
              const SizedBox(height: 32),
              if (widget.canEdit) _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Center(
      child: Obx(() {
        final hasSelectedImage = _controller.selectedImage.value != null;
        final hasExistingImage = widget.employee?.profileImageUrl != null;

        return Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey[300]!),
                image: hasSelectedImage
                    ? DecorationImage(
                  image: FileImage(_controller.selectedImage.value!),
                  fit: BoxFit.cover,
                )
                    : hasExistingImage
                    ? DecorationImage(
                  image: NetworkImage(widget.employee!.profileImageUrl!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: !hasSelectedImage && !hasExistingImage
                  ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                  : null,
            ),
            if (widget.canEdit)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue[700],
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                  onPressed: _controller.pickImage,
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: _inputDecoration('Full Name', Icons.person_outline),
      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
      readOnly: !widget.canEdit,
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        prefixIcon: const Icon(Icons.phone_outlined),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(),
        prefix: Container(
          padding: const EdgeInsets.only(right: 14),
          child: const Text('+91', style: TextStyle(fontSize: 16)),
        ),
      ),
      keyboardType: TextInputType.phone,
      maxLength: 10,
      readOnly: false, // Phone cannot be changed after creation
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Required';
        if (value!.length != 10) return 'Must be 10 digits';
        if (!value.startsWith(RegExp(r'[6-9]'))) return 'Invalid Indian number';
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: _inputDecoration('Email', Icons.email_outlined),
      readOnly: true,
      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: _inputDecoration('Password', Icons.lock_outline),
      obscureText: true,
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Required';
        if (value!.length < 6) return 'Minimum 6 characters';
        return null;
      },
    );
  }

  Widget _buildDepartmentField() {
    return TextFormField(
      controller: _departmentController,
      decoration: _inputDecoration('Department', Icons.work_outline),
      readOnly: !widget.canEdit,
    );
  }

  Widget _buildDesignationField() {
    return TextFormField(
      controller: _designationController,
      decoration: _inputDecoration('Designation', Icons.badge_outlined),
      readOnly: !widget.canEdit,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _controller.isLoading.value ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: Colors.blue[700],
          ),
          child: _controller.isLoading.value
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : Text(
            widget.employee == null ? 'CREATE EMPLOYEE' : 'SAVE CHANGES',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final companyIdValue = await Get.find<AuthService>().getCurrentUserCompanyId();
      final employee = Employee(
        email: _emailController.text.trim(),
        name: _nameController.text.trim(),
        phone: '+91${_phoneController.text.trim()}',
        companyId: companyIdValue ?? 'No company Id Found',
        isActive: widget.employee?.isActive ?? true,
        createdAt: widget.employee?.createdAt ?? DateTime.now(),
        department: _departmentController.text.trim().isEmpty
            ? null
            : _departmentController.text.trim(),
        designation: _designationController.text.trim().isEmpty
            ? null
            : _designationController.text.trim(),
        profileImageUrl: widget.employee?.profileImageUrl,
      );

      if (widget.employee == null) {
        await _controller.addEmployee(
          employee,
          _passwordController.text
        );
      } else if (widget.canEdit) {
        await _controller.updateEmployee(employee);
      }
    }
  }
}