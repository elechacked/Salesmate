import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:salesmate/features/superadmin/controllers/super_company_controller.dart';
import 'package:salesmate/features/superadmin/domain/entities/company_entity.dart';
import 'package:salesmate/app/themes/app_text_styles.dart';

class CompanyDetailScreen extends StatefulWidget {
  final String companyId;
  const CompanyDetailScreen({required this.companyId, super.key});

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  final SuperCompanyController _controller = Get.find();
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late CompanyEntity _editableCompany;
  final TextEditingController _maxUsersController = TextEditingController();
  final TextEditingController _subscriptionExpiryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.getCompanyDetails(widget.companyId).then((_) {
      if (mounted) {
        setState(() {
          _editableCompany = _controller.currentCompany!;
          _maxUsersController.text = _editableCompany.maxUsers.toString();
          _subscriptionExpiryController.text = _editableCompany.subscriptionExpiry.toLocal().toString().split(' ')[0];
        });
      }
    });
    // Initialize with empty values to avoid null
    _editableCompany = CompanyEntity(
      id: widget.companyId,
      name: '',
      ownerEmail: '',
      maxUsers: 0,
      subscriptionExpiry: DateTime.now(),
      isActive: false,
      createdAt: DateTime.now(),
      logoUrl: '',
      natureOfBusiness: '',
      gstNumber: '',
      contactNumber: '',
      address: '',
      website: '',
    );
  }

  @override
  void dispose() {
    _maxUsersController.dispose();
    _subscriptionExpiryController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _editableCompany = _controller.currentCompany!;
      }
    });
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      _controller.updateCompany(_editableCompany);
      _toggleEdit();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _editableCompany.subscriptionExpiry,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _editableCompany.subscriptionExpiry) {
      setState(() {
        _editableCompany = _editableCompany.copyWith(subscriptionExpiry: picked);
        _subscriptionExpiryController.text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.isLoading) return const Center(child: CircularProgressIndicator());
      if (_controller.errorMessage.isNotEmpty) return Center(child: Text(_controller.errorMessage));

      return Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Company' : 'Company Details', style: AppTextStyles.heading),
          actions: [
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: _isEditing ? _saveChanges : _toggleEdit,
            ),
          ],
        ),
        body: _isEditing ? _buildEditForm() : _buildDetailsView(),
      );
    });
  }

  Widget _buildDetailsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_controller.currentCompany!.logoUrl != null)
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(_controller.currentCompany!.logoUrl!),
              ),
            ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: _controller.currentCompany!.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Company ID copied to clipboard')),
              );
            },
            child: _buildDetailItem(
              'Company ID',
              _controller.currentCompany!.id,
              showCopyIcon: true,
            ),
          ),
          _buildDetailItem('Company Name', _controller.currentCompany!.name),
          _buildDetailItem('Owner Email', _controller.currentCompany!.ownerEmail),
          _buildDetailItem('Max Users', _controller.currentCompany!.maxUsers.toString()),
          _buildDetailItem(
            'Subscription Expiry',
            _controller.currentCompany!.subscriptionExpiry.toLocal().toString().split(' ')[0],
          ),
          _buildDetailItem('Status', _controller.currentCompany!.isActive ? 'Active' : 'Suspended'),
          _buildDetailItem('Nature of Business', _controller.currentCompany!.natureOfBusiness ?? 'N/A'),
          _buildDetailItem('GST Number', _controller.currentCompany!.gstNumber ?? 'N/A'),
          _buildDetailItem('Contact Number', _controller.currentCompany!.contactNumber ?? 'N/A'),
          _buildDetailItem('Address', _controller.currentCompany!.address ?? 'N/A'),
          _buildDetailItem('Website', _controller.currentCompany!.website ?? 'N/A'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _controller.currentCompany!.isActive ? Colors.red : Colors.green,
                  ),
                  onPressed: () {
                    if (_controller.currentCompany!.isActive) {
                      _controller.suspendCompany(_controller.currentCompany!.id);
                    } else {
                      _controller.activateCompany(_controller.currentCompany!.id);
                    }
                  },
                  child: Text(
                    _controller.currentCompany!.isActive ? 'Suspend Company' : 'Activate Company',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              initialValue: _editableCompany.name,
              decoration: const InputDecoration(labelText: 'Company Name'),
              onChanged: (value) => _editableCompany = _editableCompany.copyWith(name: value),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            TextFormField(
              initialValue: _editableCompany.ownerEmail,
              decoration: const InputDecoration(labelText: 'Owner Email'),
              onChanged: (value) => _editableCompany = _editableCompany.copyWith(ownerEmail: value),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            TextFormField(
              controller: _maxUsersController,
              decoration: const InputDecoration(labelText: 'Max Users'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _editableCompany = _editableCompany.copyWith(maxUsers: int.parse(value));
                }
              },
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            TextFormField(
              controller: _subscriptionExpiryController,
              decoration: const InputDecoration(labelText: 'Subscription Expiry'),
              onTap: () => _selectDate(context),
              readOnly: true,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            TextFormField(
              initialValue: _editableCompany.natureOfBusiness,
              decoration: const InputDecoration(labelText: 'Nature of Business'),
              onChanged: (value) => _editableCompany = _editableCompany.copyWith(natureOfBusiness: value),
            ),
            TextFormField(
              initialValue: _editableCompany.gstNumber,
              decoration: const InputDecoration(labelText: 'GST Number'),
              onChanged: (value) => _editableCompany = _editableCompany.copyWith(gstNumber: value),
            ),
            TextFormField(
              initialValue: _editableCompany.contactNumber,
              decoration: const InputDecoration(labelText: 'Contact Number'),
              keyboardType: TextInputType.phone,
              onChanged: (value) => _editableCompany = _editableCompany.copyWith(contactNumber: value),
            ),
            TextFormField(
              initialValue: _editableCompany.address,
              decoration: const InputDecoration(labelText: 'Address'),
              maxLines: 3,
              onChanged: (value) => _editableCompany = _editableCompany.copyWith(address: value),
            ),
            TextFormField(
              initialValue: _editableCompany.website,
              decoration: const InputDecoration(labelText: 'Website'),
              keyboardType: TextInputType.url,
              onChanged: (value) => _editableCompany = _editableCompany.copyWith(website: value),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    child: const Text('Save Changes'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _toggleEdit,
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {bool showCopyIcon = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.body.copyWith(color: Colors.grey)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(value, style: AppTextStyles.body),
              ),
              if (showCopyIcon)
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.content_copy, size: 16),
                ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}