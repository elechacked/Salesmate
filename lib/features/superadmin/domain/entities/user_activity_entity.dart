import 'package:cloud_firestore/cloud_firestore.dart';

class UserActivity {
  final String id;
  final String adminEmail;
  final String action;
  final String details;
  final DateTime timestamp;

  UserActivity({
    required this.id,
    required this.adminEmail,
    required this.action,
    required this.details,
    required this.timestamp,
  });

  factory UserActivity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserActivity(
      id: doc.id,
      adminEmail: data['adminEmail'],
      action: data['action'],
      details: data['details'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}