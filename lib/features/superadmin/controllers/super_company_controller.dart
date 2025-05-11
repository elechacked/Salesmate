import 'package:get/get.dart';
import 'package:salesmate/features/superadmin/data/repositories/company_repository.dart';
import 'package:salesmate/features/superadmin/domain/entities/company_entity.dart';
import 'package:salesmate/features/superadmin/domain/usecases/manage_company.dart';

class SuperCompanyController extends GetxController {
  final ManageCompany _manageCompany;
  final CompanyRepository _repository;

  SuperCompanyController(this._manageCompany , this._repository);

  final RxList<CompanyEntity> _companies = <CompanyEntity>[].obs;
  final Rx<CompanyEntity?> _currentCompany = Rx<CompanyEntity?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;


  List<CompanyEntity> get companies => _companies;
  CompanyEntity? get currentCompany => _currentCompany.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  Future<void> fetchCompanies() async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final result = await _manageCompany.getAllCompanies();
      _companies.assignAll(result);
    } catch (e) {
      _errorMessage.value = 'Failed to fetch companies: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<List<CompanyEntity>> getAllCompanies() async {
    try {
      _isLoading.value = true;
      final result = await _repository.getAllCompanies();
      companies.assignAll(result);
      return result;
    } catch (e) {
      _errorMessage.value = e.toString();
      return [];
    } finally {
      _isLoading.value = false;
    }
  }


  Future<CompanyEntity> getCompanyDetails(String companyId) async {
    _isLoading.value = true;
    try {
      final company = await _manageCompany.getCompanyDetails(companyId);
      _currentCompany.value = company;
      return company;
    } catch (e) {
      _errorMessage.value = 'Failed to fetch company details: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }



  Future<void> createCompany(CompanyEntity company) async {
    _isLoading.value = true;
    try {
      await _manageCompany.createCompany(company);
      _companies.add(company);
      Get.back();
      Get.snackbar('Success', 'Company created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create company: ${e.toString()}');
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateCompany(CompanyEntity company) async {
    _isLoading.value = true;
    try {
      await _manageCompany.updateCompany(company);
      final index = _companies.indexWhere((c) => c.id == company.id);
      if (index != -1) {
        _companies[index] = company;
      }
      _currentCompany.value = company;
      Get.back();
      Get.snackbar('Success', 'Company updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update company: ${e.toString()}');
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> suspendCompany(String companyId) async {
    _isLoading.value = true;
    try {
      await _manageCompany.suspendCompany(companyId);
      final index = _companies.indexWhere((c) => c.id == companyId);
      if (index != -1) {
        _companies[index] = _companies[index].copyWith(isActive: false);
      }
      if (_currentCompany.value?.id == companyId) {
        _currentCompany.value = _currentCompany.value!.copyWith(isActive: false);
      }
      Get.snackbar('Success', 'Company suspended');
    } catch (e) {
      Get.snackbar('Error', 'Failed to suspend company: ${e.toString()}');
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> activateCompany(String companyId) async {
    _isLoading.value = true;
    try {
      await _manageCompany.activateCompany(companyId);
      final index = _companies.indexWhere((c) => c.id == companyId);
      if (index != -1) {
        _companies[index] = _companies[index].copyWith(isActive: true);
      }
      if (_currentCompany.value?.id == companyId) {
        _currentCompany.value = _currentCompany.value!.copyWith(isActive: true);
      }
      Get.snackbar('Success', 'Company activated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to activate company: ${e.toString()}');
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteCompany(String companyId) async {
    _isLoading.value = true;
    try {
      await _manageCompany.deleteCompany(companyId);
      _companies.removeWhere((c) => c.id == companyId);
      if (_currentCompany.value?.id == companyId) {
        _currentCompany.value = null;
      }
      Get.back();
      Get.snackbar('Success', 'Company deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete company: ${e.toString()}');
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateSubscription(
      String companyId,
      int maxUsers,
      DateTime expiryDate,
      ) async {
    _isLoading.value = true;
    try {
      await _manageCompany.updateSubscription(companyId, maxUsers, expiryDate);
      final index = _companies.indexWhere((c) => c.id == companyId);
      if (index != -1) {
        _companies[index] = _companies[index].copyWith(
          maxUsers: maxUsers,
          subscriptionExpiry: expiryDate,
        );
      }
      if (_currentCompany.value?.id == companyId) {
        _currentCompany.value = _currentCompany.value!.copyWith(
          maxUsers: maxUsers,
          subscriptionExpiry: expiryDate,
        );
      }
      Get.back();
      Get.snackbar('Success', 'Subscription updated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update subscription: ${e.toString()}');
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }
}