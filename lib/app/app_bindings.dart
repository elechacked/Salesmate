import 'package:get/get.dart';
import 'package:salesmate/features/auth/controller/auth_controller.dart';
import 'package:salesmate/features/auth/data/auth_repository.dart';
import 'package:salesmate/features/company/controller/company_controller.dart';
import 'package:salesmate/features/company/controller/employee_controller.dart';
import 'package:salesmate/features/company/controller/profile_controller.dart';
import 'package:salesmate/features/company/controller/visits_controller.dart';
import 'package:salesmate/features/company/data/company_employee_repository.dart';
import 'package:salesmate/features/company/data/visit_repository.dart';
import 'package:salesmate/features/employee/controller/employee_home_controller.dart';
import 'package:salesmate/features/employee/controller/employee_profile_controller.dart';
import 'package:salesmate/features/employee/controller/employee_checkin_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies()  {
    Get.put(AuthRepository(), permanent: true);
    Get.put(AuthController(), permanent: true);
  }
}



    //employee bindings
class EmployeeHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EmployeeHomeController());
  }
}

class EmployeeProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EmployeeProfileController());
  }
}

class EmployeeCheckInBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EmployeeCheckInController());
  }
}

class EmployeeCheckoutBinding extends Bindings {
  @override
  void dependencies() {
    // No need to put controller here as it's created with parameters
    // when navigating to the checkout screen
  }
}

//Company Bindings




class CompanyProfileBinding extends Bindings {
@override
void dependencies() {
  Get.lazyPut(() => CompanyProfileController());// Will be implemented later

}
}

class CompanyEmployeeBinding extends Bindings {
  @override
  void dependencies() {
       // Company Module Bindings
      Get.lazyPut(() => CompanyController(), fenix: true);
      Get.lazyPut(() => CompanyEmployeeRepository(), fenix: true);
      Get.lazyPut(() => EmployeeController(), fenix: true);
  }
}

class CompanyVisitBinding extends Bindings {
  @override
  void dependencies() {
  Get.lazyPut(() => VisitController(), fenix: true,);
  Get.lazyPut(() => VisitRepository(), fenix: true,);
  }

}

