import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyEntity {
  final String id;
  late final String name;
  final String ownerEmail;
  final int maxUsers;
  final DateTime subscriptionExpiry;
  final bool isActive;
  final DateTime createdAt;
  final String? logoUrl;
  final String? natureOfBusiness;
  final String? gstNumber;
  final String? contactNumber;
  final String? address;
  final String? website;

  CompanyEntity({
    required this.id,
    required this.name,
    required this.ownerEmail,
    required this.maxUsers,
    required this.subscriptionExpiry,
    required this.isActive,
    required this.createdAt,
    this.logoUrl,
    this.natureOfBusiness,
    this.gstNumber,
    this.contactNumber,
    this.address,
    this.website,
  });

  factory CompanyEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return CompanyEntity(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      ownerEmail: data['ownerEmail']?.toString() ?? '',
      maxUsers: (data['maxUsers'] as int?) ?? 0,
      subscriptionExpiry: (data['subscriptionExpiry'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      logoUrl: data['logoUrl']?.toString(),
      natureOfBusiness: data['natureOfBusiness']?.toString(),
      gstNumber: data['gstNumber']?.toString(),
      contactNumber: data['contactNumber']?.toString(),
      address: data['address']?.toString(),
      website: data['website']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ownerEmail': ownerEmail,
      'maxUsers': maxUsers,
      'subscriptionExpiry': subscriptionExpiry,
      'isActive': isActive,
      'createdAt': createdAt,
      'logoUrl': logoUrl,
      'natureOfBusiness': natureOfBusiness,
      'gstNumber': gstNumber,
      'contactNumber': contactNumber,
      'address': address,
      'website': website,
    };
  }

  CompanyEntity copyWith({
    String? name,
    String? ownerEmail,
    int? maxUsers,
    DateTime? subscriptionExpiry,
    bool? isActive,
    String? logoUrl,
    String? natureOfBusiness,
    String? gstNumber,
    String? contactNumber,
    String? address,
    String? website,
  }) {
    return CompanyEntity(
      id: id,
      name: name ?? this.name,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      maxUsers: maxUsers ?? this.maxUsers,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      logoUrl: logoUrl ?? this.logoUrl,
      natureOfBusiness: natureOfBusiness ?? this.natureOfBusiness,
      gstNumber: gstNumber ?? this.gstNumber,
      contactNumber: contactNumber ?? this.contactNumber,
      address: address ?? this.address,
      website: website ?? this.website,
    );
  }
}