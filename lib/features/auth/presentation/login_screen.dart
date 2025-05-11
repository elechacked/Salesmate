import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:salesmate/app/app_routes.dart';
import 'package:salesmate/app/themes/app_colors.dart';
import 'package:salesmate/app/themes/app_constants.dart';
import 'package:salesmate/app/themes/app_images.dart';
import 'package:salesmate/core/utils/toast_utils.dart';
import 'package:salesmate/core/widgets/custom_text_fields.dart';
import 'package:salesmate/features/auth/controller/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = Get.find<AuthController>();

  bool _isLoading = false;
  final String _countryCode = '+91';
  final String _adminDomain = '@pska.org.in';

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final phone = _phoneController.text.trim();
        if (phone.length == 10) {
          final fullPhone = _countryCode + phone;
          final email = fullPhone.contains('@') ? fullPhone : '$fullPhone$_adminDomain';
          final password = _passwordController.text.trim();

          await _authController.login(email, password);

          if (mounted) {
            switch (_authController.userRole?.toLowerCase()) {
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
                await _authController.logout();
                ToastUtils.showErrorToast(context, 'Invalid user role. Contact admin.');
            }
          }
        } else {
          ToastUtils.showErrorToast(context, 'Please enter a valid 10-digit phone number');
        }
      } catch (e) {
        if (mounted) {
          ToastUtils.showErrorToast(context, e.toString());
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding * 1.5,
            vertical: AppConstants.defaultPadding,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Logo
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    AppImages.logo,
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 30),
                // Welcome text
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      AppColors.primaryColor,
                      AppColors.primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Login to continue to SalesMate',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.hintTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Phone number field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                      child: Text(
                        'Phone Number',
                        style: TextStyle(
                          color: AppColors.textColor.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 70,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: AppColors.hintTextColor.withOpacity(0.2),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(AppConstants.defaultBorderRadius),
                              bottomLeft: Radius.circular(AppConstants.defaultBorderRadius),
                            ),
                          ),
                          child: Text(
                            _countryCode,
                            style: TextStyle(
                              color: AppColors.textColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          child: CustomTextFormField(
                            controller: _phoneController,
                            hintText: 'Enter 10 digit number',
                            keyboardType: TextInputType.phone,
                            noBorderOnLeft: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter phone number';
                              }
                              if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                                return 'Enter 10 digit number';
                              }
                              return null;
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ], contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),

                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Password field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                      child: Text(
                        'Password',
                        style: TextStyle(
                          color: AppColors.textColor.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    CustomTextFormField(
                      controller: _passwordController,
                      hintText: 'Enter your password',
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      }, contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    ),
                  ],
                ),


                const SizedBox(height: 30),

                // Login button
                Obx(() {
                  return ElevatedButton(
                    onPressed: _authController.status == AuthStatus.authenticating
                        ? null
                        : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      ),
                    ),
                    child: _authController.status == AuthStatus.authenticating
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Divider
                const Divider(color: Colors.grey),

                const SizedBox(height: 30),

                // Footer note
                Text(
                  "Note: If you can't login please contact your Administrator",
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.hintTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}