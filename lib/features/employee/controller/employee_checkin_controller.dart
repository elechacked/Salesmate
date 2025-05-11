// lib/features/employee/controller/employee_checkin_controller.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salesmate/core/services/visit_service.dart';
import 'package:salesmate/core/utils/geo_utils.dart';
import 'package:salesmate/core/utils/upload_utils.dart';
import 'package:salesmate/models/visit_models.dart';

import '../../../core/services/time_services.dart' show TimeServices;
import '../../auth/controller/auth_controller.dart';
import 'employee_home_controller.dart';

class EmployeeCheckInController extends GetxController {
  final VisitService _visitService = Get.find<VisitService>();
  final Rx<XFile?> imageFile = Rx<XFile?>(null);
  final RxString visitingCompanyName = ''.obs;
  final RxString visitPurpose = ''.obs;
  final RxBool isLoading = false.obs;

  Future<void> captureImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 1080,
        imageQuality: 90,
      );
      if (image != null) {
        imageFile.value = image;
        Get.snackbar('Success', 'Photo captured');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to capture image: ${e.toString()}');
    }
  }

  Future<void> submitCheckIn() async {
    if (visitingCompanyName.value.isEmpty) {
      _showError('Please enter visiting company name');
      return;
    }
    if (visitPurpose.value.isEmpty) {
      _showError('Please enter visit purpose');
      return;
    }
    if (imageFile.value == null) {
      _showError('Please take a verification photo');
      return;
    }

    isLoading.value = true;

    try {
      final position = await GeoUtils.getCurrentPosition();
      if (position == null) throw 'Location access is required';

      final checkInTime = await TimeServices.getCurrentTime();
      final user = Get.find<AuthController>().currentUser;
      if (user == null || user.companyId == null) return;

      final photoUrl = await UploadUtils.uploadImage(
        type: UploadType.visitPhoto,
        imageFile: File(imageFile.value!.path),
        metadata: {
          'companyId': user.companyId!,
          'email': user.email,
          'visitId': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );

      final visit = Visit(
        id: '',
        employeeEmail: user.email,
        companyId: user.companyId!,
        visitingCompanyName: visitingCompanyName.value,
        checkInTime: checkInTime,
        checkOutTime: null,
        checkInPosition: GeoPoint(position.latitude, position.longitude),
        checkOutPosition: null,
        photoUrl: photoUrl,
        contactName: null,
        contactPhone: null,
        remarks: null,
        visitPurpose: visitPurpose.value,
        outcome: null,
        address: null,
      );

      await _visitService.createVisit(visit);
      await Get.find<EmployeeHomeController>().refreshVisits();
      Get.back(result: true); // This will trigger the refresh
      Get.snackbar('Success', 'Checked in successfully');
    } catch (e) {
      _showError('Check-in failed: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String message) {
    Get.snackbar('Error', message, backgroundColor: Colors.red);
  }
}