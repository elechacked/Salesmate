// lib/core/widgets/export/employee_selection_dialog.dart
import 'package:flutter/material.dart';
import 'package:salesmate/models/employee_models.dart';

class EmployeeSelectionDialog extends StatefulWidget {
  final List<Employee> employees;

  const EmployeeSelectionDialog({Key? key, required this.employees}) : super(key: key);

  @override
  _EmployeeSelectionDialogState createState() => _EmployeeSelectionDialogState();
}

class _EmployeeSelectionDialogState extends State<EmployeeSelectionDialog> {
  final List<bool> _selectedEmployees = [];

  @override
  void initState() {
    super.initState();
    _selectedEmployees.addAll(List<bool>.filled(widget.employees.length, false));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Employees to Export'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.employees.length,
          itemBuilder: (context, index) {
            final employee = widget.employees[index];
            return CheckboxListTile(
              title: Text(employee.name),
              subtitle: Text(employee.department ?? 'No department'),
              value: _selectedEmployees[index],
              onChanged: (value) {
                setState(() {
                  _selectedEmployees[index] = value!;
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final selected = <Employee>[];
            for (var i = 0; i < widget.employees.length; i++) {
              if (_selectedEmployees[i]) {
                selected.add(widget.employees[i]);
              }
            }
            Navigator.pop(context, selected);
          },
          child: const Text('Next'),
        ),
      ],
    );
  }
}