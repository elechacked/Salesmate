import 'package:cloud_firestore/cloud_firestore.dart';


class Employee {
    final String email;
   final String name;
    final String phone;
    final String companyId;
    final bool isActive;
    final DateTime createdAt;
    final String? profileImageUrl;
   final String? department;
    final String? designation;

  Employee({
    required this.email,
    required this.name,
    required this.phone,
    required this.companyId,
    required this.isActive,
    required this.createdAt,
    this.profileImageUrl,
    this.department,
    this.designation,
  });

  factory Employee.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Employee(
      email: doc.id,
      name: data['name']?.toString() ?? '', // Handle null with empty string
      phone: data['phone']?.toString() ?? '', // Handle null with empty string
      companyId: data['companyId']?.toString() ?? '', // Handle null with empty string
      isActive: data['isActive'] as bool? ?? false, // Handle null with false
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(), // Handle null with current time
      profileImageUrl: data['profileImageUrl']?.toString(), // Nullable field
      department: data['department']?.toString(), // Nullable field
      designation: data['designation']?.toString(), // Nullable field
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'companyId': companyId,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      if (department != null) 'department': department,
      if (designation != null) 'designation': designation,
    };
  }


    Employee copyWith({
      String? email,
      String? name,
      String? phone,
      required String? companyId,
      bool? isActive,
      DateTime? createdAt,
      String? profileImageUrl,
      String? department,
      String? designation,
    }) {
      return Employee(
        email: email ?? this.email,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        companyId: companyId ?? this.companyId,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        profileImageUrl: profileImageUrl ?? this.profileImageUrl,
        department: department ?? this.department,
        designation: designation ?? this.designation,
      );
    }
}