//company services.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:salesmate/models/company_models.dart';

import 'auth_service.dart';

class CompanyService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get companies => _firestore.collection('companies');
  CollectionReference get authProfiles => _firestore.collection('auth_profiles');

  // Existing functions (unchanged)
  Future<Company?> getCompany(String companyId) async {
    final doc = await companies.doc(companyId).get();
    return doc.exists ? Company.fromFirestore(doc) : null;
  }

  Future<DocumentSnapshot> getCompanyDoc(String companyId) async {
    final doc = await companies.doc(companyId).get();
    if (!doc.exists) {
      throw Exception('Company document not found');
    }
    return doc;
  }

  // New functions
  Future<Company?> getCurrentUserCompany() async {
    final companyId = await Get.find<AuthService>().getCurrentUserCompanyId();
    if (companyId == null) return null;
    return await getCompany(companyId);
  }

  Future<void> updateCompany(Company company) async {
    await companies.doc(company.id).update(company.toFirestore());
  }



  Future<int> getEmployeeCount(String companyId) async {
    final count = await companies.doc(companyId)
        .collection('employees')
        .count()
        .get();
    return count.count!;
  }
}