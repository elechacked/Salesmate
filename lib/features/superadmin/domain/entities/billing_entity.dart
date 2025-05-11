import 'package:cloud_firestore/cloud_firestore.dart';

class BillingRecord {
  final String invoiceId;
  final String companyId;
  final String companyName;
  final double amount;
  final String currency;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final String status;
  final String planName;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int userLimit;

  BillingRecord({
    required this.invoiceId,
    required this.companyId,
    required this.companyName,
    required this.amount,
    required this.currency,
    required this.invoiceDate,
    required this.dueDate,
    required this.status,
    required this.planName,
    required this.periodStart,
    required this.periodEnd,
    required this.userLimit,
  });

  factory BillingRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BillingRecord(
      invoiceId: doc.id,
      companyId: data['companyId'],
      companyName: data['companyName'],
      amount: (data['amount'] as num).toDouble(),
      currency: data['currency'] ?? 'INR',
      invoiceDate: (data['invoiceDate'] as Timestamp).toDate(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      planName: data['planName'] ?? 'Standard',
      periodStart: (data['periodStart'] as Timestamp).toDate(),
      periodEnd: (data['periodEnd'] as Timestamp).toDate(),
      userLimit: data['userLimit'] ?? 10,
    );
  }
}

class BillingSummary {
  final double totalRevenue;
  final double pendingAmount;
  final int activeSubscriptions;
  final int expiringSoon;

  BillingSummary({
    required this.totalRevenue,
    required this.pendingAmount,
    required this.activeSubscriptions,
    required this.expiringSoon,
  });
}