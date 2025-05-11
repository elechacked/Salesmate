//storage_service.dart

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Reference get storageRoot => _storage.ref();
  Reference companyLogos(String companyId) => storageRoot.child('company_logos/$companyId');
  Reference employeePhotos(String companyId, String employeeEmail) =>
      storageRoot.child('companies/$companyId/employees/$employeeEmail/profile.jpg');
  Reference visitPhotos(String companyId, String employeeEmail, String visitId) =>
      storageRoot.child('companies/$companyId/employees/$employeeEmail/visits/$visitId/photo.jpg');

  Future<String> uploadFile({
    required Reference ref,
    required String filePath,
  }) async {
    final uploadTask = ref.putFile(File(filePath));
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> deleteFile(Reference ref) async {
    try {
      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }
  }
}