import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:salesmate/app/app.dart';
import 'package:salesmate/core/services/firestore_services.dart';
import 'package:salesmate/firebase_options.dart';

import 'core/services/auth_service.dart';
import 'core/services/company_service.dart' show CompanyService;
import 'core/services/employee_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/user_service.dart';
import 'core/services/visit_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();

  Get.config(
    enableLog: true,
    logWriterCallback: customLogWriter,
  );
  Get.put(AuthService());
  Get.put(CompanyService());
  Get.put(EmployeeService());
  Get.put(VisitService());
  Get.put(StorageService());
  Get.put(UserService());
  Get.put(FirestoreService());
  // 4. Run the app
  runApp(MyApp());
}

void customLogWriter(String text, {bool isError = false}) {
  debugPrint('🔥 [GETX LOG] ${isError ? "ERROR" : "INFO"}: $text');
}