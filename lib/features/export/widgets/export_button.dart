// lib/core/widgets/export/export_button.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesmate/features/export/presentation/export_options.dart';

class ExportButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const ExportButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.upload),
      tooltip: 'Export',
      onPressed: onPressed ?? () => Get.to(() => ExportOptionsScreen()),
    );
  }
}