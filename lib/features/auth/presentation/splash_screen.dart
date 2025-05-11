// lib/app/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:salesmate/app/app_routes.dart';
import 'package:salesmate/app/themes/app_colors.dart';
import 'package:salesmate/app/themes/app_constants.dart';
import 'package:salesmate/app/themes/app_images.dart';
import 'package:salesmate/features/auth/controller/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuthStatus());
  }

  Future<void> _checkAuthStatus() async {
    try {
      await _waitForInitialization();
      if (!mounted) return;

      await _authController.tryAutoLogin();

      if (!mounted) return;

      if (_authController.currentUser != null) {
        _redirectBasedOnRole(_authController.currentUser!.role);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      debugPrint('Auth check error: $e');
      if (mounted) Get.offAllNamed(AppRoutes.login);
    }
  }

  void _redirectBasedOnRole(String role) {
    switch (role.toLowerCase()) {
      case 'employee':
        Get.offAllNamed(AppRoutes.employeeHome);
        break;
      case 'company':
        Get.offAllNamed(AppRoutes.companyDashboard);
        break;
      case 'superadmin':
        Get.offAllNamed(AppRoutes.superadminDashboard);
        break;
      default:
        Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> _waitForInitialization() async {
    const maxAttempts = 5;
    const delayDuration = Duration(milliseconds: 500);

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      if (Get.isRegistered<AuthController>()) return;
      await Future.delayed(delayDuration);
    }

    throw Exception('Dependencies not initialized');
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppImages.logo,
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}