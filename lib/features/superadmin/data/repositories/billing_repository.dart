import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salesmate/features/superadmin/domain/entities/billing_entity.dart';

class BillingRepository {
  final FirebaseFirestore firestore;

  BillingRepository({required this.firestore});

  Future<List<BillingRecord>> getBillingRecords({String? companyId}) async {
    Query query = firestore.collection('billing_records');

    if (companyId != null) {
      query = query.where('companyId', isEqualTo: companyId);
    }

    final snapshot = await query.orderBy('invoiceDate', descending: true).get();
    return snapshot.docs.map((doc) => BillingRecord.fromFirestore(doc)).toList();
  }

  Future<void> createInvoice(BillingRecord invoice) async {
    await firestore.collection('billing_records').doc(invoice.invoiceId).set({
      'invoiceId': invoice.invoiceId,
      'companyId': invoice.companyId,
      'companyName': invoice.companyName,
      'amount': invoice.amount,
      'currency': invoice.currency,
      'invoiceDate': invoice.invoiceDate,
      'dueDate': invoice.dueDate,
      'status': invoice.status,
      'planName': invoice.planName,
      'periodStart': invoice.periodStart,
      'periodEnd': invoice.periodEnd,
      'userLimit': invoice.userLimit,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<BillingSummary> getBillingSummary() async {
    final companies = await firestore.collection('companies').get();
    final invoices = await firestore.collection('billing_records').get();

    double totalRevenue = 0;
    double pendingAmount = 0;
    int activeSubscriptions = 0;
    int expiringSoon = 0;

    final now = DateTime.now();
    final soon = now.add(const Duration(days: 30));

    for (final company in companies.docs) {
      final expiry = (company.data()['subscriptionExpiry'] as Timestamp).toDate();
      if (expiry.isAfter(now)) {
        activeSubscriptions++;
        if (expiry.isBefore(soon)) {
          expiringSoon++;
        }
      }
    }

    for (final invoice in invoices.docs) {
      final data = invoice.data();
      totalRevenue += (data['amount'] as num).toDouble();
      if (data['status'] == 'pending') {
        pendingAmount += (data['amount'] as num).toDouble();
      }
    }

    return BillingSummary(
      totalRevenue: totalRevenue,
      pendingAmount: pendingAmount,
      activeSubscriptions: activeSubscriptions,
      expiringSoon: expiringSoon,
    );
  }
}