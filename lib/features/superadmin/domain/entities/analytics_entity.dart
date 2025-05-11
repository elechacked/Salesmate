class AnalyticsEntity {
  final int totalCompanies;
  final int activeCompanies;
  final int totalEmployees;
  final int totalVisits;
  final int activeVisits;

  AnalyticsEntity({
    required this.totalCompanies,
    required this.activeCompanies,
    required this.totalEmployees,
    required this.totalVisits,
    required this.activeVisits,
  });

  double get averageVisitsPerCompany => totalCompanies > 0
      ? totalVisits / totalCompanies
      : 0;

  double get averageVisitsPerEmployee => totalEmployees > 0
      ? totalVisits / totalEmployees
      : 0;
}

class CompanyVisits {
  final String companyId;
  final String companyName;
  final int visitCount;

  CompanyVisits({
    required this.companyId,
    required this.companyName,
    required this.visitCount,
  });
}