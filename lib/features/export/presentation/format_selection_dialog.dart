// lib/core/widgets/export/format_selection_dialog.dart
import 'package:flutter/material.dart';

class FormatSelectionDialog extends StatelessWidget {
  const FormatSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Export Format'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Excel'),
            leading: const Icon(Icons.table_chart),
            onTap: () => Navigator.pop(context, 'Excel'),
          ),
          ListTile(
            title: const Text('CSV'),
            leading: const Icon(Icons.grid_on),
            onTap: () => Navigator.pop(context, 'CSV'),
          ),
        ],
      ),
    );
  }
}