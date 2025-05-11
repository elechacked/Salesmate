import 'package:salesmate/features/superadmin/data/repositories/billing_repository.dart';
import 'package:salesmate/features/superadmin/domain/entities/billing_entity.dart';

class ManageBilling {
  final BillingRepository repository;

  ManageBilling(this.repository);

  Future<List<BillingRecord>> getBillingRecords({String? companyId}) =>
      repository.getBillingRecords(companyId: companyId);
  Future<void> createInvoice(BillingRecord invoice) =>
      repository.createInvoice(invoice);
  Future<BillingSummary> getBillingSummary() => repository.getBillingSummary();
}