import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddEventsScreen extends StatefulWidget {
  const AddEventsScreen({super.key});

  @override
  State<AddEventsScreen> createState() => _AddEventsScreenState();
}

class _AddEventsScreenState extends State<AddEventsScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _submitEvents() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _startTime != null &&
        _endTime != null) {
      final selectedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
      );

      await FirebaseFirestore.instance.collection('Company Events').add({
        'date': selectedDateTime,
        'startTime': _startTime!.format(context),
        'endTime': _endTime!.format(context),
        'description': _descriptionController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event added successfully'),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTimeRange(BuildContext context) async {
    final TimeOfDay? start = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (start != null) {
      final TimeOfDay? end = await showTimePicker(
        context: context,
        initialTime: start.replacing(hour: start.hour + 1), // 1 hour later
      );

      if (end != null) {
        setState(() {
          _startTime = start;
          _endTime = end;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade600,
        title: const Text('Add Company Events'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Event Description',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      _selectedDate == null
                          ? 'No Date chosen'
                          : 'Picked Date: ${DateFormat.yMd().format(_selectedDate!)}',
                    ),
                    TextButton(
                      onPressed: () => _pickDate(context),
                      child: const Text('Choose Date'),
                    )
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _startTime == null || _endTime == null
                          ? 'No Time Range Selected'
                          : 'Time: ${_startTime!.format(context)} - ${_endTime!.format(context)}',
                    ),
                    TextButton(
                      onPressed: () => _pickTimeRange(context),
                      child: const Text('Choose Time Range'),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitEvents,
                  child: const Text('Submit Event'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
