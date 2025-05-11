// lib/features/company/controllers/company_profile_controller.dart

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:salesmate/core/services/company_service.dart';
import 'package:salesmate/core/utils/upload_utils.dart';
import 'package:salesmate/models/company_models.dart';

class CompanyProfileController extends GetxController {
  final CompanyService _companyService = Get.find();
  final Rx<Company?> company = Rx<Company?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString logoUrl = ''.obs;
  final RxBool hasChanges = false.obs;

  // Controllers for editable fields
  final nameController = TextEditingController();
  final natureOfBusinessController = TextEditingController();
  final gstNumberController = TextEditingController();
  final addressController = TextEditingController();
  final websiteController = TextEditingController();

  // For read-only fields
  final ownerEmailController = TextEditingController();
  final contactNumberController = TextEditingController();
  final maxUsersController = TextEditingController();
  final subscriptionExpiry = RxString('');

  @override
  void onInit() {
    super.onInit();
    loadCompanyProfile();

    // Listen to changes
    nameController.addListener(_checkChanges);
    natureOfBusinessController.addListener(_checkChanges);
    gstNumberController.addListener(_checkChanges);
    addressController.addListener(_checkChanges);
    websiteController.addListener(_checkChanges);
  }

  void _checkChanges() {
    hasChanges.value = true;
  }

  Future<void> loadCompanyProfile() async {
    try {
      isLoading(true);
      final companyData = await _companyService.getCurrentUserCompany();
      if (companyData != null) {
        company.value = companyData;
        logoUrl.value = companyData.logoUrl ?? '';

        // Set editable fields
        nameController.text = companyData.name;
        natureOfBusinessController.text = companyData.natureOfBusiness ?? '';
        gstNumberController.text = companyData.gstNumber ?? '';
        addressController.text = companyData.address ?? '';
        websiteController.text = companyData.website ?? '';

        // Set read-only fields
        ownerEmailController.text = companyData.ownerEmail;
        contactNumberController.text = companyData.contactNumber ?? '';
        maxUsersController.text = companyData.maxUsers.toString();
        subscriptionExpiry.value = DateFormat('MMM dd, yyyy').format(companyData.subscriptionExpiry);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load company profile');
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateLogo() async {
    try {
      final imageFile = await UploadUtils.pickAndCompressImage(ImageSource.gallery);
      if (imageFile == null) return;

      isLoading.value = true;
      logoUrl.value = await UploadUtils.uploadImage(
        type: UploadType.companyLogo,
        imageFile: imageFile,
        metadata: {
          'companyId': company.value?.id ?? '',
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update logo');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveProfile() async {
    try {
      isSaving(true);
      if (company.value != null) {
        final updatedCompany = company.value!.copyWith(
          name: nameController.text,
          natureOfBusiness: natureOfBusinessController.text,
          gstNumber: gstNumberController.text,
          address: addressController.text,
          website: websiteController.text,
          logoUrl: logoUrl.value,
        );

        await _companyService.updateCompany(updatedCompany);
        company.value = updatedCompany;
        hasChanges.value = false;
        Get.snackbar('Success', 'Profile updated successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save profile');
    } finally {
      isSaving(false);
    }
  }
}




