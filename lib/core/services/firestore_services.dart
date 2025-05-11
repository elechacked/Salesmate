//firestore services.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FirestoreService extends GetxService {
  static FirestoreService get to => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseFirestore get instance => _firestore;

  @override
  void onInit() {
    super.onInit();
  }
}