// lib/models/export_config.dart
class ExportConfig {
  final List<String> availableFormats;
  final List<String> defaultEmployeeColumns;
  final List<String> defaultVisitColumns;
  final Map<String, List<String>> formatColumns;

  const ExportConfig({
    this.availableFormats = const ['PDF', 'Excel', 'CSV'],
    this.defaultEmployeeColumns = const [
      'Name',
      'Email',
      'Phone',
      'Department',
      'Designation',
      'Status',
    ],
    this.defaultVisitColumns = const [
      'Company',
      'Contact Name',
      'Contact Number',
      'Address',
      'Outcome',
      'Photo',
      'Check-in Time',
      'Check-out Time',
      'Duration',
      'Purpose',
     ],
    this.formatColumns = const {
      'Excel': ['all'],
      'CSV': ['all'],
    },
  });

  List<String> getColumnsForFormat(String format, {bool isEmployee = false}) {
    if (formatColumns[format]?.contains('all') ?? false) {
      return isEmployee ? defaultEmployeeColumns : defaultVisitColumns;
    }
    return formatColumns[format] ??
        (isEmployee ? defaultEmployeeColumns : defaultVisitColumns);
  }
}