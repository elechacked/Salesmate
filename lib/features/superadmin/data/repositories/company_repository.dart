import 'package:salesmate/features/superadmin/data/datasources/company_remote_datasource.dart';
import 'package:salesmate/features/superadmin/domain/entities/company_entity.dart';

class CompanyRepository {
  final CompanyRemoteDataSource remoteDataSource;

  CompanyRepository({required this.remoteDataSource});

  Future<List<CompanyEntity>> getAllCompanies() async {
    return await remoteDataSource.fetchAllCompanies();
  }

  Future<CompanyEntity> getCompanyDetails(String companyId) async {
    return await remoteDataSource.fetchCompanyDetails(companyId);
  }

  Future<void> createCompany(CompanyEntity company) async {
    await remoteDataSource.createCompany(company);
  }

  Future<void> updateCompany(CompanyEntity company) async {
    await remoteDataSource.updateCompany(company);
  }

  Future<void> suspendCompany(String companyId) async {
    await remoteDataSource.suspendCompany(companyId);
  }

  Future<void> activateCompany(String companyId) async {
    await remoteDataSource.activateCompany(companyId);
  }

  Future<void> deleteCompany(String companyId) async {
    await remoteDataSource.deleteCompany(companyId);
  }

  Future<void> updateSubscription(
      String companyId, int maxUsers, DateTime expiryDate) async {
    await remoteDataSource.updateSubscription(companyId, maxUsers, expiryDate);
  }
}