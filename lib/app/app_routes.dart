import 'package:get/get.dart';
import 'package:salesmate/core/middleware/auth_middleware.dart';
import 'package:salesmate/core/middleware/role_middleware.dart';
import 'package:salesmate/features/export/widgets/export_dialog.dart';
import 'package:salesmate/features/auth/presentation/login_screen.dart';
import 'package:salesmate/features/auth/presentation/splash_screen.dart';
import 'package:salesmate/features/company/presentation/dashboard/company_dashboard.dart';
import 'package:salesmate/features/company/presentation/employees/employee_create.dart';
import 'package:salesmate/features/company/presentation/employees/employee_list.dart';
import 'package:salesmate/features/company/presentation/employees/employee_view.dart';
import 'package:salesmate/features/company/presentation/profile/company_profile.dart';
import 'package:salesmate/features/company/presentation/visits/employee_visits_list.dart';
import 'package:salesmate/features/company/presentation/visits/visit_dashboard.dart';
import 'package:salesmate/features/company/presentation/visits/visit_detail.dart';
import 'package:salesmate/features/employee/presentation/employee_home_screen.dart';
import 'package:salesmate/features/employee/presentation/employee_profile_screen.dart';
import 'package:salesmate/features/employee/presentation/employee_checkin_screen.dart';
import 'package:salesmate/features/employee/presentation/employee_checkout_screen.dart';
import 'package:salesmate/features/export/presentation/export_options.dart';
// import 'package:salesmate/features/superadmin/presentation//admin_list.dart';
import 'package:salesmate/features/superadmin/presentation/screens/companies/company_create.dart';
import 'package:salesmate/features/superadmin/presentation/screens/companies/company_list.dart';
import 'package:salesmate/features/superadmin/presentation/screens/dashboard/superadmin_dashboard.dart';
import 'package:salesmate/features/superadmin/presentation/screens/users/user_create_screen.dart';
import 'package:salesmate/features/superadmin/presentation/screens/users/user_details.dart';
import 'package:salesmate/features/superadmin/presentation/screens/users/user_list.dart';
import 'package:salesmate/features/superadmin/superadmin_bindings.dart';
import 'package:salesmate/models/employee_models.dart';
import 'package:salesmate/models/export_config.dart';
import 'package:salesmate/models/visit_models.dart';

import '../features/superadmin/presentation/screens/companies/company_detail.dart';
import 'app_bindings.dart';

abstract class AppRoutes {
  // Common routes
  static const String splash = '/';
  static const String login = '/login';

  //export routes
  static const String exportOptions = '/export-options';
  static const String exportDialog = '/export-dialog';

  // Employee routes
  static const String employeeHome = '/employee/home';
  static const String employeeProfile = '/employee/profile';
  static const String employeeCheckin = '/employee/checkin';
  static const String employeeCheckout = '/employee/checkout';
//Company routes

  static const companyDashboard = '/company/dashboard';
  static const companyProfile = '/company/profile';

  //employee managgement
  static const companyEmployees = '/company/employees';
  static const companyEmployeeCreate = '/company/employees/create';
  static const companyEmployeeEdit = '/company/employees/edit';
  static const companyEmployeeView = '/company/employees/view';


  //visit management

  static const companyVisits = '/company/visits';
  static const companyEmployeeVisits = '/company/visits/employee';
  static const companyVisitDetail = '/company/visits/detail';

  // Superadmin routes
  static const superadminDashboard = '/superadmin/dashboard';
  static const companyList = '/superadmin/companies';
  static const companyDetail = '/superadmin/companies/detail';
  static const companyCreate = '/superadmin/companies/create';

  static final routes = [
    // Core routes
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.exportOptions,
      page: () => ExportOptionsScreen(),
    ),
    GetPage(
      name: AppRoutes.exportDialog,
      page: () => ExportDialog(
        format: Get.arguments as String,
        selectedColumns: ExportConfig().defaultVisitColumns,
        onColumnsChanged: (cols) {},
      ),
    ),
   // Employee routes
    GetPage(
      name: employeeHome,
      page: () => const EmployeeHomeScreen(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: ['employee']),
      ],
      binding: EmployeeHomeBinding(),
    ),
    GetPage(
      name: employeeProfile,
      page: () => const EmployeeProfileScreen(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: ['employee']),
      ],
      binding: EmployeeProfileBinding(),
    ),
    GetPage(
      name: employeeCheckin,
      page: () => EmployeeCheckInScreen(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: ['employee']),
      ],
      binding: EmployeeCheckInBinding(),
    ),
    GetPage(
      name: employeeCheckout,
      page: () {
        final Visit visit = Get.arguments as Visit;
        return EmployeeCheckoutScreen(visit: visit);
      },
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: ['employee']),
      ],
      binding: EmployeeCheckoutBinding(),
    ),




//Company Routes
    GetPage(
      name: AppRoutes.companyDashboard,
      page: () => CompanyDashboardScreen(),
      binding: CompanyEmployeeBinding(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(allowedRoles: ['company']),
      ],
    ),
    // Add placeholders for other company screens
    GetPage(
      name: AppRoutes.companyProfile,
      page: () =>  CompanyProfileScreen(),
        binding: CompanyProfileBinding(),
        middlewares: [
          AuthMiddleware(),
          RoleMiddleware(allowedRoles: ['company']),
        ],
    ),







    //Company Visit Management tab
    GetPage(
      name: companyVisits,
      page: () => VisitDashboard(),
      binding: CompanyVisitBinding(),
    ),
    GetPage(
      name: companyEmployeeVisits,
      page: () => EmployeeVisitsList(),
      binding: CompanyVisitBinding(),
    ),
    GetPage(
      name: companyVisitDetail,
      page: () => VisitDetailScreen(),
      binding: CompanyVisitBinding(),
    ),









    //company employee management
    GetPage(
      name: AppRoutes.companyEmployees,
      page: () => EmployeeListScreen(),
      binding: CompanyEmployeeBinding(),
    ),
    GetPage(
      name: companyEmployeeCreate,
      page: () => EmployeeCreateScreen(),
      binding: CompanyEmployeeBinding(),

    ),
    GetPage(
      name: companyEmployeeEdit,
      page: () {
        final employee = Get.arguments as Employee;
        return EmployeeCreateScreen(employee: employee);
      },
      binding: CompanyEmployeeBinding(),

    ),
    GetPage(
      name: companyEmployeeView,
      page: () {
        final employee = Get.arguments as Employee;
        return EmployeeViewScreen(employee: employee);
      },
      binding: CompanyEmployeeBinding(),
    ),


    // Superadmin routes

    GetPage(
      name: AppRoutes.superadminDashboard,
      page: () => const SuperadminDashboard(),
      binding: SuperadminBindings(),
      middlewares: [RoleMiddleware(allowedRoles: ['superadmin'])],
    ),
    GetPage(
      name: AppRoutes.companyList,
      page: () => const CompanyListScreen(),
      binding: SuperadminBindings(),
      middlewares: [RoleMiddleware(allowedRoles: ['superadmin'])],
    ),
    GetPage(
      name: AppRoutes.companyDetail,
      page: () =>  CompanyDetailScreen(companyId: Get.arguments),
      binding: SuperadminBindings(),
      middlewares: [RoleMiddleware(allowedRoles: ['superadmin'])],
    ),
    GetPage(
      name: AppRoutes.companyCreate,
      page: () =>  CompanyCreateScreen(),
      binding: SuperadminBindings(),
      middlewares: [RoleMiddleware(allowedRoles: ['superadmin'])],
    ),



    GetPage(
      name: '/superadmin/users',
      page: () => const UserListScreen(),
    ),
    GetPage(
      name: '/superadmin/users/create',
      page: () => const CreateUserScreen(),
    ),
    GetPage(
      name: '/superadmin/users/detail',
      page: () => UserDetailsScreen(userEmail: Get.arguments),
    ),

  ];
}


