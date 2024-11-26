import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MultiDatePicker extends StatefulWidget {
  const MultiDatePicker({super.key, required this.onDateSelected});
  final Function(List<DateTime>) onDateSelected;
  @override
  State<MultiDatePicker> createState() => _MultiDatePickerState();
}

class _MultiDatePickerState extends State<MultiDatePicker> {
  List<DateTime> selectedDates = [];

  @override
  Widget build(BuildContext context) {
     return Column(
      children: [
        ElevatedButton(
          onPressed: _selectDates,
          child: const Text('Select Leave Dates'),
        ),
        if (selectedDates.isNotEmpty)
          Text(
            'Selected Dates: ${selectedDates.map((e) => DateFormat('yyyy-MM-dd').format(e)).join(', ')}',
            style: const TextStyle(fontSize: 16),
          ),
      ],
    );
  }

  Future<void> _selectDates() async {
    final today = DateTime.now();
    final lastDate = today.add(const Duration(days: 30));

    final pickedDates = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: lastDate,
      builder: (context, child) {
        return Column(
          children: [
            child!,
            // Any extra customization if needed
          ],
        );
      },
    );

    if (pickedDates != null) {
      setState(() {
        selectedDates.add(pickedDates);
      });

      widget.onDateSelected(selectedDates);
    }
  }
}