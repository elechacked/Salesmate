// lib/features/export/presentation/export_options.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesmate/models/export_config.dart';

class ExportOptionsScreen extends StatelessWidget {
  final ExportConfig config = const ExportConfig();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export Options')),
      body: ListView.builder(
        itemCount: config.availableFormats.length,
        itemBuilder: (context, index) {
          final format = config.availableFormats[index];
          return ListTile(
            title: Text(format),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.toNamed('/export-dialog', arguments: format),
          );
        },
      ),
    );
  }
}