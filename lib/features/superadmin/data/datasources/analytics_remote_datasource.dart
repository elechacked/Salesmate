import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsRemoteDataSource {
  final FirebaseFirestore firestore;

  AnalyticsRemoteDataSource({required this.firestore});

  Future<int> getTotalCompanies() async {
    final snapshot = await firestore.collection('companies').count().get();
    return snapshot.count!.toInt(); // Returns raw count
  }

  Future<List<Map<String, dynamic>>> getCompanyVisits() async {
    final snapshot = await firestore.collection('visits').get();
    return snapshot.docs.map((doc) => doc.data()).toList(); // Raw Firestore data
  }
}