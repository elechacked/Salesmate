// lib/models/visit_models.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class Visit {
   final String id;
    final String employeeEmail;
    final String companyId;
    final String visitingCompanyName;
    final DateTime checkInTime;
    final DateTime? checkOutTime;
    final GeoPoint checkInPosition;
    final GeoPoint? checkOutPosition;
   final String photoUrl;
   final String? contactName;
    final String? contactPhone;
    final String? remarks;
    final String? visitPurpose;
    final String? outcome;
    final String? address;

  Visit({
    required this.id,
    required this.employeeEmail,
    required this.companyId,
    required this.visitingCompanyName,
    required this.checkInTime,
    this.checkOutTime,
    required this.checkInPosition,
    this.checkOutPosition,
    required this.photoUrl,
     this.contactName,
     this.contactPhone,
    this.remarks,
    this.visitPurpose,
    this.outcome,
     this.address,
  });



  factory Visit.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Ensure GeoPoint fields are properly handled
    GeoPoint? parseGeoPoint(dynamic value) {
      if (value == null) return null;
      if (value is GeoPoint) return value;
      if (value is Map<String, dynamic>) {
        return GeoPoint(value['latitude'], value['longitude']);
      }
      return null;
    }

    return Visit(
      id: doc.id,
      employeeEmail: data['employeeEmail']?.toString() ?? '',
      companyId: data['companyId']?.toString() ?? '',
      visitingCompanyName: data['companyName']?.toString() ?? '',
      checkInTime: (data['checkInTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      checkOutTime: (data['checkOutTime'] as Timestamp?)?.toDate(),
      checkInPosition: parseGeoPoint(data['checkInPosition']) ??
          GeoPoint(0, 0), // Default position
      checkOutPosition: parseGeoPoint(data['checkOutPosition']),
      photoUrl: data['photoUrl']?.toString() ?? '',
      contactName: data['contactName']?.toString(),
      contactPhone: data['contactPhone']?.toString(),
      remarks: data['remarks']?.toString(),
      visitPurpose: data['visitPurpose']?.toString(),
      outcome: data['outcome']?.toString(),
      address: data['address']?.toString(),
    );
  }

  String get formattedDuration {
    if (duration == null) return 'N/A';

    final totalMinutes = duration!.inMinutes;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}hr ${minutes}min';
    } else if (hours > 0) {
      return '${hours}hr';
    } else {
      return '${minutes}min';
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'employeeEmail': employeeEmail,
      'companyId': companyId,
      'companyName': visitingCompanyName,
      'checkInTime': Timestamp.fromDate(checkInTime),
      'checkOutTime': checkOutTime != null
          ? Timestamp.fromDate(checkOutTime!)
          : null,
      if (checkOutTime != null) 'checkOutTime': Timestamp.fromDate(checkOutTime!),
      'checkInPosition': checkInPosition,
      if (checkOutPosition != null) 'checkOutPosition': checkOutPosition,
      'photoUrl': photoUrl,
      if (contactName != null) 'contactName': contactName,
      if (contactPhone != null) 'contactPhone': contactPhone,
      if (remarks != null) 'remarks': remarks,
      if (visitPurpose != null) 'visitPurpose': visitPurpose,
      if (outcome != null) 'outcome': outcome,
      if (address != null) 'address': address,

    };
  }
  Map<String, dynamic> toDisplayMap() {
    return {
      'Employee Email': employeeEmail,
      'Company': companyId,
      'companyName': visitingCompanyName,
      'Check-in Time': DateFormat('MMM dd, yyyy - hh:mm a').format(checkInTime),
      'Check-out Time': checkOutTime != null
          ? DateFormat('MMM dd, yyyy - hh:mm a').format(checkOutTime!)
          : 'Ongoing',
      'Duration': formattedDuration,
      'Contact Name': contactName ?? 'N/A',
      'Contact Phone': contactPhone ?? 'N/A',
      'Purpose': visitPurpose ?? 'N/A',
      'Outcome': outcome ?? 'N/A',
      'Remarks': remarks ?? 'N/A',
      'address': address ?? 'N/A',
    };
  }

   // Add this to your Visit model class
   Visit copyWith({
     String? id,
     String? employeeEmail,
     String? companyId,
     String? visitingCompanyName,
     DateTime? checkInTime,
     DateTime? checkOutTime,
     GeoPoint? checkInPosition,
     GeoPoint? checkOutPosition,
     String? photoUrl,
     String? contactName,
     String? contactPhone,
     String? remarks,
     String? visitPurpose,
     String? outcome,
     String? address,
   }) {
     return Visit(
       id: id ?? this.id,
       employeeEmail: employeeEmail ?? this.employeeEmail,
       companyId: companyId ?? this.companyId,
       visitingCompanyName: visitingCompanyName ?? this.visitingCompanyName,
       checkInTime: checkInTime ?? this.checkInTime,
       checkOutTime: checkOutTime ?? this.checkOutTime,
       checkInPosition: checkInPosition ?? this.checkInPosition,
       checkOutPosition: checkOutPosition ?? this.checkOutPosition,
       photoUrl: photoUrl ?? this.photoUrl,
       contactName: contactName ?? this.contactName,
       contactPhone: contactPhone ?? this.contactPhone,
       remarks: remarks ?? this.remarks,
       visitPurpose: visitPurpose ?? this.visitPurpose,
       outcome: outcome ?? this.outcome,
       address: address ?? this.address,
     );
   }



  bool get isOngoing => checkOutTime == null;

  Duration? get duration =>
      checkOutTime != null ? checkOutTime!.difference(checkInTime) : null;
   VisitStatus get status {
     if (checkOutTime == null) return VisitStatus.ongoing;
     if (outcome?.toLowerCase() == 'cancelled') return VisitStatus.cancelled;
     return VisitStatus.completed;
   }
}

enum VisitStatus { ongoing, completed, cancelled }

