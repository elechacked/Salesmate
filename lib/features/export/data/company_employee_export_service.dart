// lib/core/services/company_employee_export_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:salesmate/models/employee_models.dart';

class CompanyEmployeeExportService {
  static Future<void> exportEmployees({
    required List<Employee> employees,
    required String format,
    required List<String> columns,
    required BuildContext context,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/employees_export.${format.toLowerCase()}';
      final file = File(filePath);

      if (format == 'Excel') {
        await exportToExcel(employees, columns, file);
      }  else if (format == 'CSV') {
        await exportToCSV(employees, columns, file);
      }

      await Share.shareXFiles([XFile(filePath)]);
    } catch (e) {
      throw Exception('Export failed: ${e.toString()}');
    }
  }

  static Future<void> exportToExcel(
      List<Employee> employees,
      List<String> columns,
      File file,
      ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Employees'];

    // Add headers
    final headers = <CellValue>[];
    if (columns.contains('Name')) headers.add(TextCellValue('Name'));
    if (columns.contains('Email')) headers.add(TextCellValue('Email'));
    if (columns.contains('Phone')) headers.add(TextCellValue('Phone'));
    if (columns.contains('Department')) headers.add(TextCellValue('Department'));
    if (columns.contains('Designation')) headers.add(TextCellValue('Designation'));
    if (columns.contains('Status')) headers.add(TextCellValue('Status'));

    sheet.appendRow(headers);

    // Add data
    for (var employee in employees) {
      final row = <CellValue>[];
      if (columns.contains('Name')) row.add(TextCellValue(employee.name));
      if (columns.contains('Email')) row.add(TextCellValue(employee.email));
      if (columns.contains('Phone')) row.add(TextCellValue(employee.phone));
      if (columns.contains('Department')) row.add(TextCellValue(employee.department ?? 'N/A'));
      if (columns.contains('Designation')) row.add(TextCellValue(employee.designation ?? 'N/A'));
      if (columns.contains('Status')) row.add(TextCellValue(employee.isActive ? 'Active' : 'Inactive'));

      sheet.appendRow(row);
    }

    await file.writeAsBytes(excel.encode()!);
  }



  static Future<void> exportToCSV(
      List<Employee> employees,
      List<String> columns,
      File file,
      ) async {
    final csvData = StringBuffer();

    // Add headers
    final headers = _getCsvHeaders(columns);
    csvData.writeln(headers.join(','));

    // Add data
    for (var employee in employees) {
      final row = _getCsvRow(employee, columns);
      csvData.writeln(row.join(','));
    }

    await file.writeAsString(csvData.toString());
  }





  static List<String> _getCsvHeaders(List<String> columns) {
    final headers = <String>[];
    if (columns.contains('Name')) headers.add('Name');
    if (columns.contains('Email')) headers.add('Email');
    if (columns.contains('Phone')) headers.add('Phone');
    if (columns.contains('Department')) headers.add('Department');
    if (columns.contains('Designation')) headers.add('Designation');
    if (columns.contains('Status')) headers.add('Status');
    return headers;
  }

  static List<String> _getCsvRow(Employee employee, List<String> columns) {
    final row = <String>[];
    if (columns.contains('Name')) row.add('"${employee.name.replaceAll('"', '""')}"');
    if (columns.contains('Email')) row.add('"${employee.email}"');
    if (columns.contains('Phone')) row.add('"${employee.phone}"');
    if (columns.contains('Department')) row.add('"${employee.department?.replaceAll('"', '""') ?? 'N/A'}"');
    if (columns.contains('Designation')) row.add('"${employee.designation?.replaceAll('"', '""') ?? 'N/A'}"');
    if (columns.contains('Status')) row.add('"${employee.isActive ? 'Active' : 'Inactive'}"');
    return row;
  }
}