import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salesmate/features/superadmin/data/datasources/company_remote_datasource.dart';
import 'package:salesmate/features/superadmin/data/datasources/user_remote_datasource.dart';
import 'package:salesmate/features/superadmin/data/datasources/billing_remote_datasource.dart';
import 'package:salesmate/features/superadmin/data/datasources/analytics_remote_datasource.dart';
import 'package:salesmate/features/superadmin/data/repositories/company_repository.dart';
import 'package:salesmate/features/superadmin/data/repositories/user_repository.dart';
import 'package:salesmate/features/superadmin/data/repositories/billing_repository.dart';
import 'package:salesmate/features/superadmin/data/repositories/analytics_repository.dart';
import 'package:salesmate/features/superadmin/domain/usecases/get_companies.dart';
import 'package:salesmate/features/superadmin/domain/usecases/manage_company.dart';
import 'package:salesmate/features/superadmin/domain/usecases/manage_user.dart';
import 'package:salesmate/features/superadmin/domain/usecases/manage_billing.dart';
import 'package:salesmate/features/superadmin/domain/usecases/get_analytics.dart';


import 'controllers/user_controller.dart';
import 'controllers/analytics_controller.dart';
import 'controllers/billing_controller.dart';
import 'controllers/super_company_controller.dart';
import 'controllers/superadmin_controller.dart';

class SuperadminBindings implements Bindings {
  @override
  void dependencies() {
    // Initialize Firestore
    final firestore = FirebaseFirestore.instance;
    Get.lazyPut<FirebaseFirestore>(() => FirebaseFirestore.instance);
    final firebaseAuth = FirebaseAuth.instance;


    Get.lazyPut<FirebaseAuth>(() => firebaseAuth);
    Get.lazyPut<FirebaseFirestore>(() => firestore);

    // Data sources
    Get.lazyPut(() => CompanyRemoteDataSource(firestore: firestore));
    Get.lazyPut<UserRemoteDataSource>(() => UserRemoteDataSource(
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
    ));   Get.lazyPut(() => BillingRemoteDataSource(firestore: firestore));
    Get.lazyPut(() => AnalyticsRemoteDataSource(firestore: firestore));

    // Repositories
    Get.lazyPut(() => CompanyRepository(remoteDataSource: Get.find()));
    Get.lazyPut<UserRepository>(() => UserRepository(
      remoteDataSource: Get.find(),
    ));
    Get.lazyPut(() => BillingRepository(firestore: Get.find()));
    Get.lazyPut(() => AnalyticsRepository(firestore: Get.find()));

    // Use cases
    Get.lazyPut(() => GetCompanies(Get.find()));
    Get.lazyPut(() => ManageCompany(Get.find()));
    Get.lazyPut<ManageUser>(() => ManageUser(
      repository: Get.find(),
    ));
    Get.lazyPut(() => ManageBilling(Get.find()));
    Get.lazyPut(() => GetAnalytics(Get.find()));

    // Controllers
    Get.lazyPut(() => SuperadminController(getCompanies: Get.find()));
    Get.lazyPut(() => SuperCompanyController(Get.find(), Get.find()));
    Get.lazyPut<UserController>(() => UserController(manageUser: Get.find())); 
    Get.lazyPut(() => BillingController(manageBilling: Get.find()));
    Get.lazyPut(() => AnalyticsController(getAnalytics: Get.find()));
  }
}