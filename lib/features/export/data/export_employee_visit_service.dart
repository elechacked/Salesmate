import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:salesmate/features/company/controller/visits_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:salesmate/models/employee_models.dart';
import 'package:salesmate/models/export_config.dart';
import 'package:salesmate/models/visit_models.dart';

class ExportEmployeeVisitService {
  final ExportConfig config = const ExportConfig();
  final VisitController _visitController = Get.find<VisitController>();

  Future<void> exportEmployeeVisits({
    required String format,
    required List<String> selectedColumns,
    bool singleEmployee = false,
  }) async {
    try {
      final data = await _prepareExportData(singleEmployee);
      final employeeName = singleEmployee
          ? _visitController.selectedEmployee.value?.name ?? 'employee'
          : 'all_employees';

      switch (format) {
        case 'CSV':
          await _exportToCsv(data, selectedColumns, employeeName);
          break;
        case 'Excel':
          await _exportToExcel(data, selectedColumns, employeeName);
          break;
        default:
          throw Exception('Unsupported export format');
      }
    } catch (e) {
      Get.snackbar('Export Failed', e.toString());
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> _prepareExportData(bool singleEmployee) async {
    final data = <Map<String, dynamic>>[];

    if (singleEmployee) {
      final employee = _visitController.selectedEmployee.value;
      if (employee != null) {
        for (final visit in _visitController.employeeVisits) {
          data.add({
            'employee': employee,
            'visit': visit,
          });
        }
      }
    } else {
      final allData = await _visitController.getAllEmployeesWithVisits();
      for (final item in allData) {
        for (final visit in item.visits) {
          data.add({
            'employee': item.employee,
            'visit': visit,
          });
        }
      }
    }

    return data;
  }

  Future<void> _exportToCsv(
      List<Map<String, dynamic>> data,
      List<String> columns,
      String employeeName,
      ) async {
    final List<List<dynamic>> csvData = [];
    csvData.add(columns);

    for (final item in data) {
      csvData.add(_getRowData(item['employee'], item['visit'], columns));
    }

    final csv = const ListToCsvConverter().convert(csvData);
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/${employeeName}_visits_${DateTime.now().millisecondsSinceEpoch}.csv';
    await File(path).writeAsString(csv);
    await Share.shareFiles([path], text: 'Exported visits for $employeeName');
  }

  Future<void> _exportToExcel(
      List<Map<String, dynamic>> data,
      List<String> columns,
      String employeeName,
      ) async {
    // Create a new Excel document
    final excel = Excel.createExcel();
    final sheet = excel['Employee Visits'];

    // Add header row with styling
    sheet.appendRow(columns.map((col) => TextCellValue(col)).toList());

    // Format for date cells
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    // Add data rows
    for (final item in data) {
      final rowData = _getRowData(item['employee'], item['visit'], columns);
      sheet.appendRow(rowData.map((cell) {
        if (cell == null) {
          return TextCellValue('');
        } else if (cell is DateTime) {
          return TextCellValue(dateFormat.format(cell));
        } else if (cell is String && cell == 'Ongoing') {
          return TextCellValue(cell);
        }
        return TextCellValue(cell.toString());
      }).toList());
    }

    // Set column widths
    for (var i = 0; i < columns.length; i++) {
      sheet.setColumnWidth(i, 20);
    }

    // Save the file
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/${employeeName}_visits_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.encode()!);

    await Share.shareFiles([path], text: 'Exported visits for $employeeName');
  }



  List<dynamic> _getRowData(Employee employee, Visit visit, List<String> columns) {
    final row = <dynamic>[];
    for (final column in columns) {
      switch (column) {
        case 'Name':
          row.add(employee.name);
          break;
        case 'Email':
          row.add(employee.email);
          break;
        case 'Phone':
          row.add(employee.phone);
          break;
        case 'Department':
          row.add(employee.department ?? 'N/A');
          break;
        case 'Designation':
          row.add(employee.designation ?? 'N/A');
          break;
        case 'Status':
          row.add(employee.isActive ? 'Active' : 'Inactive');
          break;
        case 'Company':
          row.add(visit.visitingCompanyName);
          break;
        case 'Check-in Time':
          row.add(visit.checkInTime);
          break;
        case 'Check-out Time':
          row.add(visit.checkOutTime ?? 'Ongoing');
          break;
        case 'Duration':
          row.add(visit.formattedDuration);
          break;
        case 'Purpose':
          row.add(visit.visitPurpose ?? 'N/A');
          break;
        case 'Outcome':
          row.add(visit.outcome ?? 'N/A');
          break;
        case 'Photo':
          row.add(visit.photoUrl.isNotEmpty ? 'Yes' : 'No');
          break;
        case 'Contact Name':
          row.add(visit.contactName ?? 'N/A');
          break;
        case 'Contact Phone':
          row.add(visit.contactPhone ?? 'N/A');
          break;
        case 'Remarks':
          row.add(visit.remarks ?? 'N/A');
          break;
        case 'Address':
          row.add(visit.address ?? 'N/A');
        default:
          row.add('');
      }
    }
    return row;
  }

  bool get singleEmployee => _visitController.selectedEmployee.value != null;
}
