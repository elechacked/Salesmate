import 'package:flutter/material.dart';
import 'package:salesmate/models/export_config.dart';

class ExportDialog extends StatefulWidget {
  final String format;
  final List<String> selectedColumns;
  final Function(List<String>) onColumnsChanged;
  final bool isEmployee;

  const ExportDialog({
    Key? key,
    required this.format,
    required this.selectedColumns,
    required this.onColumnsChanged,
    this.isEmployee = false,
  }) : super(key: key);

  @override
  _ExportDialogState createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  late List<bool> _selectedColumns;

  @override
  void initState() {
    super.initState();
    final config = ExportConfig();
    final allColumns = widget.isEmployee
        ? config.defaultEmployeeColumns
        : config.defaultVisitColumns;
    _selectedColumns = List<bool>.generate(
      allColumns.length,
          (i) => widget.selectedColumns.contains(allColumns[i]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = ExportConfig();
    final allColumns = widget.isEmployee
        ? config.defaultEmployeeColumns
        : config.defaultVisitColumns;

    return AlertDialog(
      title: Text('${widget.format} Export Options'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            const Text('Select columns to include:'),
            const SizedBox(height: 16),
            ...List.generate(allColumns.length, (index) {
              return CheckboxListTile(
                title: Text(allColumns[index]),
                value: _selectedColumns[index],
                onChanged: (value) {
                  setState(() {
                    _selectedColumns[index] = value!;
                  });
                  _updateSelectedColumns();
                },
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            _updateSelectedColumns();
            Navigator.pop(context, widget.selectedColumns);
          },
          child: const Text('Export'),
        ),
      ],
    );
  }



  void _updateSelectedColumns() {
    final config = ExportConfig();
    final allColumns = widget.isEmployee
        ? config.defaultEmployeeColumns
        : config.defaultVisitColumns;
    final selected = <String>[];
    for (var i = 0; i < _selectedColumns.length; i++) {
      if (_selectedColumns[i]) {
        selected.add(allColumns[i]);
      }
    }
    widget.onColumnsChanged(selected);
  }
}