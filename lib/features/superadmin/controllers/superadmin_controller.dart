import 'package:get/get.dart';
import 'package:salesmate/features/superadmin/domain/usecases/get_companies.dart';
import 'package:salesmate/features/superadmin/domain/entities/company_entity.dart';

class SuperadminController extends GetxController {
  final GetCompanies getCompanies;

  SuperadminController({required this.getCompanies});

  final RxList<CompanyEntity> companies = <CompanyEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    fetchCompanies();
    super.onInit();
  }

  Future<void> fetchCompanies() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await getCompanies();
      companies.assignAll(result);
    } catch (e) {
      errorMessage.value = 'Failed to fetch companies: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void filterCompanies(String query) {
    if (query.isEmpty) {
      fetchCompanies();
      return;
    }

    final filtered = companies.where((company) =>
    company.name.toLowerCase().contains(query.toLowerCase()) ||
        company.ownerEmail.toLowerCase().contains(query.toLowerCase()) ||
        (company.gstNumber?.toLowerCase().contains(query.toLowerCase()) ?? false)).toList();

    companies.assignAll(filtered);
  }
}