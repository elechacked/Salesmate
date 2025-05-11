import 'package:salesmate/features/superadmin/data/repositories/company_repository.dart';
import 'package:salesmate/features/superadmin/domain/entities/company_entity.dart';

class ManageCompany {
  final CompanyRepository repository;

  ManageCompany(this.repository);

  Future<List<CompanyEntity>> getAllCompanies() => repository.getAllCompanies();
  Future<CompanyEntity> getCompanyDetails(String companyId) =>
      repository.getCompanyDetails(companyId);
  Future<void> createCompany(CompanyEntity company) =>
      repository.createCompany(company);
  Future<void> updateCompany(CompanyEntity company) =>
      repository.updateCompany(company);
  Future<void> suspendCompany(String companyId) =>
      repository.suspendCompany(companyId);
  Future<void> activateCompany(String companyId) =>
      repository.activateCompany(companyId);
  Future<void> deleteCompany(String companyId) =>
      repository.deleteCompany(companyId);
  Future<void> updateSubscription(
      String companyId,
      int maxUsers,
      DateTime expiryDate,
      ) => repository.updateSubscription(companyId, maxUsers, expiryDate);
}