import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddHolidayScreen extends StatefulWidget {
  const AddHolidayScreen({super.key});
  @override
  State<AddHolidayScreen> createState() {
    return _AddHolidayScreenState();
  }
}

class _AddHolidayScreenState extends State<AddHolidayScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _submitHoliday() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      await FirebaseFirestore.instance.collection('Compney Holiday').add({
        'date': _selectedDate,
        'description': _descriptionController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Holiday added successfully'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade600,
        title: const Text('Add Holiday'),
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
                    labelText: 'Holiday',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'plese enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Text(
                      _selectedDate == null
                          ? 'No Date choosen'
                          : 'picked Date: ${DateFormat.yMd().format(_selectedDate!)}',
                    ),
                    TextButton(
                      onPressed: () => _pickDate(context),
                      child: const Text('Choose Date'),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: _submitHoliday,
                    child: const Text('submit Holiday'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
