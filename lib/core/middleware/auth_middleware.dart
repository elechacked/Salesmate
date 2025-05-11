import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:salesmate/app/app_routes.dart';
import 'package:salesmate/features/auth/data/auth_repository.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    try {
      if (!Get.isRegistered<AuthRepository>()) return null;

      final authRepo = Get.find<AuthRepository>();
      final hasToken = authRepo.token != null;
      final isLoginRoute = route == AppRoutes.login;

      if (isLoginRoute && hasToken) {
        return _redirectBasedOnRole(authRepo.user?.role);
      }

      if (!isLoginRoute && !hasToken) {
        return const RouteSettings(name: AppRoutes.login);
      }

      return null;
    } catch (e) {
      debugPrint('AuthMiddleware error: $e');
      return const RouteSettings(name: AppRoutes.login);
    }
  }

  RouteSettings? _redirectBasedOnRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'employee': return const RouteSettings(name: AppRoutes.employeeHome);
      case 'company': return const RouteSettings(name: AppRoutes.companyDashboard);
      case 'superadmin': return const RouteSettings(name: AppRoutes.superadminDashboard);
      default: return const RouteSettings(name: AppRoutes.login);
    }
  }
}