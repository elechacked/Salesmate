import 'package:get/get.dart';
import 'package:salesmate/core/services/company_service.dart';
import 'package:salesmate/models/company_models.dart';

class CompanyController extends GetxController {
  final CompanyService _companyService = Get.find();
  final Rx<Company?> company = Rx<Company?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCompanyData();
  }

  Future<void> loadCompanyData() async {
    try {
      isLoading.value = true;
      company.value = await _companyService.getCurrentUserCompany();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load company data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshCompanyData() async {
    await loadCompanyData();
  }
}