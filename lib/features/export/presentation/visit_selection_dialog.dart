// lib/core/widgets/export/visit_selection_dialog.dart
import 'package:flutter/material.dart';
import 'package:salesmate/models/visit_models.dart';

class VisitSelectionDialog extends StatefulWidget {
  final List<Visit> visits;

  const VisitSelectionDialog({super.key, required this.visits});

  @override
  _VisitSelectionDialogState createState() => _VisitSelectionDialogState();
}

class _VisitSelectionDialogState extends State<VisitSelectionDialog> {
  final List<bool> _selectedVisits = [];

  @override
  void initState() {
    super.initState();
    _selectedVisits.addAll(List<bool>.filled(widget.visits.length, false));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Visits to Export'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.visits.length,
          itemBuilder: (context, index) {
            final visit = widget.visits[index];
            return CheckboxListTile(
              title: Text(visit.visitingCompanyName),
              subtitle: Text(visit.checkInTime.toString()),
              value: _selectedVisits[index],
              onChanged: (value) {
                setState(() {
                  _selectedVisits[index] = value!;
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
            final selected = <Visit>[];
            for (var i = 0; i < widget.visits.length; i++) {
              if (_selectedVisits[i]) {
                selected.add(widget.visits[i]);
              }
            }
            Navigator.pop(context, selected);
          },
          child: const Text('Export'),
        ),
      ],
    );
  }
}