// lib/core/utils/network_utils.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkUtils {
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  static void showNoInternetSnackbar() {
    Get.snackbar(
      'No Internet Connection',
      'Please check your network settings',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}