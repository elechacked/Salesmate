import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salesmate/features/superadmin/domain/entities/company_entity.dart';

class CompanyRemoteDataSource {
  final FirebaseFirestore firestore;

  CompanyRemoteDataSource({required this.firestore});

  Future<List<CompanyEntity>> fetchAllCompanies() async {
    final snapshot = await firestore.collection('companies').get();
    return snapshot.docs
        .map((doc) => CompanyEntity.fromFirestore(doc))
        .toList();
  }

  Future<CompanyEntity> fetchCompanyDetails(String companyId) async {
    final doc = await firestore.collection('companies').doc(companyId).get();
    return CompanyEntity.fromFirestore(doc);
  }

  Future<void> createCompany(CompanyEntity company) async {
    // Let Firestore auto-generate the ID for new companies
    final docRef = firestore.collection('companies').doc();

    await docRef.set({
      'id': docRef.id, // Store the generated ID in the document
      'name': company.name,
      'ownerEmail': company.ownerEmail,
      'maxUsers': company.maxUsers,
      'subscriptionExpiry': company.subscriptionExpiry,
      'isActive': company.isActive,
      'createdAt': FieldValue.serverTimestamp(),
      'logoUrl': company.logoUrl,
      'natureOfBusiness': company.natureOfBusiness,
      'gstNumber': company.gstNumber,
      'contactNumber': company.contactNumber,
      'address': company.address,
      'website': company.website,
    });
  }

  Future<void> updateCompany(CompanyEntity company) async {
    await firestore.collection('companies').doc(company.id).update({
      'name': company.name,
      'ownerEmail': company.ownerEmail,
      'maxUsers': company.maxUsers,
      'subscriptionExpiry': company.subscriptionExpiry,
      'isActive': company.isActive,
      'logoUrl': company.logoUrl,
      'natureOfBusiness': company.natureOfBusiness,
      'gstNumber': company.gstNumber,
      'contactNumber': company.contactNumber,
      'address': company.address,
      'website': company.website,
    });
  }

  Future<void> suspendCompany(String companyId) async {
    await firestore.collection('companies').doc(companyId).update({
      'isActive': false,
    });
  }

  Future<void> activateCompany(String companyId) async {
    await firestore.collection('companies').doc(companyId).update({
      'isActive': true,
    });
  }

  Future<void> deleteCompany(String companyId) async {
    await firestore.collection('companies').doc(companyId).delete();
  }

  Future<void> updateSubscription(
      String companyId, int maxUsers, DateTime expiryDate) async {
    await firestore.collection('companies').doc(companyId).update({
      'maxUsers': maxUsers,
      'subscriptionExpiry': expiryDate,
    });
  }
}