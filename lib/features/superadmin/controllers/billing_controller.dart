import 'package:get/get.dart';
import 'package:salesmate/features/superadmin/domain/entities/billing_entity.dart';
import 'package:salesmate/features/superadmin/domain/usecases/manage_billing.dart';

class BillingController extends GetxController {
  final ManageBilling manageBilling;

  BillingController({required this.manageBilling});

  final RxList<BillingRecord> billingRecords = <BillingRecord>[].obs;
  final Rx<BillingSummary?> billingSummary = Rx<BillingSummary?>(null);
  final RxBool isLoading = false.obs;
  final RxString filterCompanyId = RxString('');

  Future<void> fetchBillingData() async {
    isLoading.value = true;
    try {
      final records = await manageBilling.getBillingRecords(
        companyId: filterCompanyId.value.isEmpty ? null : filterCompanyId.value,
      );
      billingRecords.assignAll(records);

      if (filterCompanyId.value.isEmpty) {
        final summary = await manageBilling.getBillingSummary();
        billingSummary.value = summary;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createInvoice(BillingRecord invoice) async {
    try {
      await manageBilling.createInvoice(invoice);
      billingRecords.insert(0, invoice);
      Get.back();
      Get.snackbar('Success', 'Invoice created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create invoice: ${e.toString()}');
    }
  }

  void setCompanyFilter(String companyId) {
    filterCompanyId.value = companyId;
    fetchBillingData();
  }

  void clearCompanyFilter() {
    filterCompanyId.value = '';
    fetchBillingData();
  }
}