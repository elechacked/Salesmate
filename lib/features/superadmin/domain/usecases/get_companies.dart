import 'package:salesmate/features/superadmin/data/repositories/company_repository.dart';
import 'package:salesmate/features/superadmin/domain/entities/company_entity.dart';

class GetCompanies {
  final CompanyRepository repository;

  GetCompanies(this.repository);

  Future<List<CompanyEntity>> call() async {
    return await repository.getAllCompanies();
  }
}