import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:salesmate/features/auth/controller/auth_controller.dart';

class RoleMiddleware extends GetMiddleware {
  final List<String> allowedRoles;

  RoleMiddleware({required this.allowedRoles});

  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    final userRole = authController.userRole;

    if (userRole == null || !allowedRoles.contains(userRole)) {
      return const RouteSettings(name: '/unauthorized');
    }
    return null;
  }
}