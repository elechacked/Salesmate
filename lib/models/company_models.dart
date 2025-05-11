import 'package:cloud_firestore/cloud_firestore.dart';

class Company {
   final String id;
       final String name;
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

  Company({
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

  factory Company.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Company(
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

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'ownerEmail': ownerEmail,
      'maxUsers': maxUsers,
      'subscriptionExpiry': Timestamp.fromDate(subscriptionExpiry),
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      if (logoUrl != null) 'logoUrl': logoUrl,
      if (natureOfBusiness != null) 'natureOfBusiness': natureOfBusiness,
      if (gstNumber != null) 'gstNumber': gstNumber,
      if (contactNumber != null) 'contactNumber': contactNumber,
      if (address != null) 'address': address,
      if (website != null) 'website': website,
    };
  }

  Company copyWith({
    String? name,
    String? logoUrl,
    String? natureOfBusiness,
    String? gstNumber,
    String? contactNumber,
    String? address,
    String? website,
  }) {
    return Company(
      id: id,
      name: name ?? this.name,
      ownerEmail: ownerEmail,
      maxUsers: maxUsers,
      subscriptionExpiry: subscriptionExpiry,
      isActive: isActive,
      createdAt: createdAt,
      logoUrl: logoUrl ?? this.logoUrl,
      natureOfBusiness: natureOfBusiness ?? this.natureOfBusiness,
      gstNumber: gstNumber ?? this.gstNumber,
      contactNumber: contactNumber ?? this.contactNumber,
      address: address ?? this.address,
      website: website ?? this.website,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Company &&
        other.id == id &&
        other.name == name &&
        other.ownerEmail == ownerEmail &&
        other.logoUrl == logoUrl &&
        other.gstNumber == gstNumber &&
        other.maxUsers == maxUsers &&
        other.subscriptionExpiry == subscriptionExpiry &&
        other.natureOfBusiness == natureOfBusiness &&
        other.contactNumber == contactNumber &&
        other.address == address &&
        other.website == website &&
        other.createdAt == createdAt &&
    other.isActive == isActive;
  }
  @override
  int get hashCode => Object.hash(
    id,
    name,
    ownerEmail,
    logoUrl,
    gstNumber,
    maxUsers,
    subscriptionExpiry,
    natureOfBusiness,
    contactNumber,
    address,
    website,
    isActive,
    createdAt,
  );
}