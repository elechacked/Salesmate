// lib/features/employee/controller/employee_checkout_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesmate/core/services/visit_service.dart';
import 'package:salesmate/core/utils/geo_utils.dart';
import 'package:salesmate/models/visit_models.dart';

import '../../../core/services/time_services.dart';
import 'employee_home_controller.dart';

class EmployeeCheckoutController extends GetxController {
  final VisitService _visitService = Get.find<VisitService>();
  final Visit visit;

  final contactNameController = TextEditingController();
  final contactPhoneController = TextEditingController();
  final remarksController = TextEditingController();
  final addressController = TextEditingController();

  final Rx<DateTime> currentTime = DateTime.now().obs;
  final RxString selectedOutcome = 'Successful'.obs;
  final RxBool isLoading = false.obs;

  EmployeeCheckoutController({required this.visit}) {
    _updateCurrentTime();
  }

  void _updateCurrentTime() async {
    currentTime.value = await TimeServices.getCurrentTime();
    Future.delayed(const Duration(seconds: 1), _updateCurrentTime);
  }

  Future<void> submitCheckout() async {
    if (contactNameController.text.isEmpty) {
      _showError('Please enter contact person name');
      return;
    }
    if (addressController.text.isEmpty) {
      _showError('Please enter the address');
      return;
    }
    if (contactPhoneController.text.isEmpty) {
      _showError('Please enter contact phone number');
      return;
    }
    if (!_isValidPhoneNumber(contactPhoneController.text)) {
      _showError('Please enter a valid 10-digit phone number');
      return;
    }

    isLoading.value = true;

    try {
      final position = await GeoUtils.getCurrentPosition();
      if (position == null) throw 'Location services required';

      final checkoutTime = await TimeServices.getCurrentTime();

      final updatedVisit = visit.copyWith(
        checkOutTime: checkoutTime,
        checkOutPosition: GeoPoint(position.latitude, position.longitude),
        contactName: contactNameController.text,
        contactPhone: contactPhoneController.text,
        remarks: remarksController.text,
        outcome: selectedOutcome.value,
        address: addressController.text,
      );

      await _visitService.updateVisit(updatedVisit);
      await Get.find<EmployeeHomeController>().refreshVisits();
      Get.back(result: true); // This will trigger the refresh
      Get.snackbar('Success', 'Checked out successfully');
    } catch (e) {
      _showError('Checkout failed: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  bool _isValidPhoneNumber(String phone) {
    return RegExp(r'^(\+91|91)?[6-9]\d{9}$').hasMatch(phone);
  }

  void _showError(String message) {
    Get.snackbar('Error', message, backgroundColor: Colors.red);
  }

  @override
  void onClose() {
    contactNameController.dispose();
    contactPhoneController.dispose();
    remarksController.dispose();
    addressController.dispose();
    super.onClose();
  }
}