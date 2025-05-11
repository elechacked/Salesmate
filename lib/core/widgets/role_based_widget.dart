import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesmate/features/auth/controller/auth_controller.dart';

class RoleBasedWidget extends StatelessWidget {
  final Widget? employeeWidget;
  final Widget? companyWidget;
  final Widget? superAdminWidget;
  final Widget? fallbackWidget;

  const RoleBasedWidget({
    super.key,
    this.employeeWidget,
    this.companyWidget,
    this.superAdminWidget,
    this.fallbackWidget,
  });

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final role = authController.userRole?.toLowerCase();

    switch (role) {
      case 'employee':
        return employeeWidget ?? fallbackWidget ?? const SizedBox();
      case 'company':
        return companyWidget ?? fallbackWidget ?? const SizedBox();
      case 'superadmin':
        return superAdminWidget ?? fallbackWidget ?? const SizedBox();
      default:
        return fallbackWidget ?? const SizedBox();
    }
  }
}

// Example usage:
// RoleBasedWidget(
//   employeeWidget: EmployeeDashboard(),
//   companyWidget: CompanyDashboard(),
//   superAdminWidget: AdminDashboard(),
//   fallbackWidget: AccessDeniedScreen(),
// )

class RoleBasedBuilder extends StatelessWidget {
  final Widget Function(BuildContext)? employeeBuilder;
  final Widget Function(BuildContext)? companyBuilder;
  final Widget Function(BuildContext)? superAdminBuilder;
  final Widget Function(BuildContext)? fallbackBuilder;

  const RoleBasedBuilder({
    super.key,
    this.employeeBuilder,
    this.companyBuilder,
    this.superAdminBuilder,
    this.fallbackBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final role = authController.userRole?.toLowerCase();

    switch (role) {
      case 'employee':
        return employeeBuilder?.call(context) ??
            fallbackBuilder?.call(context) ??
            const SizedBox();
      case 'company':
        return companyBuilder?.call(context) ??
            fallbackBuilder?.call(context) ??
            const SizedBox();
      case 'superadmin':
        return superAdminBuilder?.call(context) ??
            fallbackBuilder?.call(context) ??
            const SizedBox();
      default:
        return fallbackBuilder?.call(context) ?? const SizedBox();
    }
  }
}

