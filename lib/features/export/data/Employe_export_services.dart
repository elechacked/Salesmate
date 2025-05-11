// lib/core/services/export_service.dart

import 'dart:io';
import 'package:flutter/cupertino.dart' show BuildContext, Text;
import 'package:flutter/material.dart' show ScaffoldMessenger, SnackBar;
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:salesmate/models/visit_models.dart';
import 'package:salesmate/core/utils/date_utils.dart';

class EmployeeExportService {
  static Future<void> exportVisits({
    required List<Visit> visits,
    required String format,
    required List<String> columns,
    required BuildContext context,
  }) async {
    try {
      if (format == 'Excel') {
        await _exportToExcel(visits, columns, context);
      }  else if (format == 'CSV') {
        await _exportToCSV(visits, columns, context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: ${e.toString()}')),
      );
      rethrow;
    }
  }

  static Future<void> _exportToExcel(
      List<Visit> visits,
      List<String> columns,
      BuildContext context,
      ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Visits'];

    // Prepare headers based on selected columns
    final headers = <CellValue>[];
    if (columns.contains('Company')) headers.add(TextCellValue('Company'));
    if (columns.contains('Contact Name')) headers.add(TextCellValue('Contact name'));
    if (columns.contains('Contact Number')) headers.add(TextCellValue('Contact Number'));
    if (columns.contains('Address')) headers.add(TextCellValue('Address'));
    if (columns.contains('Purpose')) headers.add(TextCellValue('Purpose'));
    if (columns.contains('Outcome')) headers.add(TextCellValue('Outcome'));
    if (columns.contains('Check-in Time')) headers.add(TextCellValue('Check-in Time'));
    if (columns.contains('Check-out Time')) headers.add(TextCellValue('Check-out Time'));
    if (columns.contains('Duration')) headers.add(TextCellValue('Duration'));
    if (columns.contains('Photo')) headers.add(TextCellValue('Photo'));



    sheet.appendRow(headers);

    // Add data
    for (var visit in visits) {
      final row = <CellValue>[];
      if (columns.contains('Company')) row.add(TextCellValue(visit.visitingCompanyName));
      if(columns.contains('Contact Name')) row.add(TextCellValue(visit.contactName ?? 'N/A'));
      if(columns.contains('Contact Number')) row.add(TextCellValue(visit.contactPhone?? 'N/A'));
      if(columns.contains('Address')) row.add(TextCellValue(visit.address ?? 'N/A'));
      if (columns.contains('Purpose')) row.add(TextCellValue(visit.visitPurpose ?? 'N/A'));
      if (columns.contains('Outcome')) row.add(TextCellValue(visit.outcome ?? 'N/A'));
      if (columns.contains('Check-in Time')) {
        row.add(TextCellValue(DateUtils.formatForExport(visit.checkInTime)));
      }
      if (columns.contains('Check-out Time')) {
        row.add(TextCellValue(
            visit.checkOutTime != null
                ? DateUtils.formatForExport(visit.checkOutTime!)
                : 'N/A'
        ));
      }
      if (columns.contains('Duration')) {
        row.add(TextCellValue(
            visit.duration != null
                ? DateUtils.formatDurationForExport(visit.duration!)
                : 'N/A'
        ));
      }
      if(visit.photoUrl != null) {
        String photo = "Yes";

        if (columns.contains('Photo')) row.add(TextCellValue(photo));
      }
      sheet.appendRow(row);
    }

    // Save and share
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/visits_export.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    await Share.shareXFiles([XFile(filePath)], text: 'Exported Visits');
  }



  static Future<void> _exportToCSV(
      List<Visit> visits,
      List<String> columns,
      BuildContext context,
      ) async {
    final csvData = StringBuffer();

    // Add headers
    final headers = <String>[];
    if (columns.contains('Company')) headers.add('Company');
    if(columns.contains('Contact Phone')) headers.add('Contact Phone');
    if(columns.contains('Contact Name')) headers.add('Contact Name');
    if(columns.contains('Address')) headers.add('Address');
    if (columns.contains('Purpose')) headers.add('Purpose');
    if (columns.contains('Outcome')) headers.add('Outcome');
    if (columns.contains('Check-in Time')) headers.add('Check-in Time');
    if (columns.contains('Check-out Time')) headers.add('Check-out Time');
    if (columns.contains('Duration')) headers.add('Duration');
    if (columns.contains('Photo')) headers.add('Photo URL');


    csvData.writeln(headers.join(','));

    // Add data
    for (var visit in visits) {
      final row = <String>[];
      if (columns.contains('Company')) row.add('"${visit.visitingCompanyName}"');
      if (columns.contains('Address')) row.add('"${visit.address}"');
      if (columns.contains('Contact Name')) row.add('"${visit.contactName}"');
      if (columns.contains('Contact Phone')) row.add('"${visit.contactPhone}"');
      if (columns.contains('Check-in Time')) {
        row.add('"${DateUtils.formatForExport(visit.checkInTime)}"');
      }
      if (columns.contains('Check-out Time')) {
        row.add('"${visit.checkOutTime != null
            ? DateUtils.formatForExport(visit.checkOutTime!)
            : 'N/A'}"');
      }
      if (columns.contains('Duration')) {
        row.add('"${visit.duration != null
            ? DateUtils.formatDurationForExport(visit.duration!)
            : 'N/A'}"');
      }
      if (columns.contains('Purpose')) row.add('"${visit.visitPurpose ?? 'N/A'}"');
      if (columns.contains('Outcome')) row.add('"${visit.outcome ?? 'N/A'}"');
      if(visit.photoUrl != null) {
        String photo = "Yes";
        if (columns.contains('Photo')) row.add(photo);

      }


      csvData.writeln(row.join(','));
    }

    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/visits_export.csv';
    final file = File(filePath);
    await file.writeAsString(csvData.toString());

    await Share.shareXFiles([XFile(filePath)], text: 'Exported Visits');
  }
}