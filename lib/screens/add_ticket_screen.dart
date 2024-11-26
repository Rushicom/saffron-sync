import 'dart:io';
import 'dart:typed_data';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:task/widgets/tabs.dart';

class AddTicketScreen extends StatefulWidget {
  const AddTicketScreen({super.key});

  @override
  State<AddTicketScreen> createState() => _TicketUserState();
}

class _TicketUserState extends State<AddTicketScreen> {
  bool _isLoading = false;
  List<DateTime> _selectedDates = [];
  final Map<String, int> _leaveCounts = {
    'casual': 28,
    'medical': 28,
    'unpaid': 0,
  };
  final _formKey = GlobalKey<FormState>();
  String? _uid;
  String? _name;
  String? _title;
  String? _category;
  String? _description;
  String? _mainCategory;
  String? _subCategory;
  DateTime? _dateOfRequirement;
  final _status = 'Open';
  String? _fileUrl;
  String? _selectedFileName;
  final TextEditingController _dateController = TextEditingController();

  void _updateLeaveCounts() {
    if (_mainCategory == 'leaves' && _subCategory != null) {
      int validateLeaveCount = countValidLeaves(_selectedDates);
      setState(() {
        _leaveCounts.updateAll((key, value) => 0);
        _leaveCounts[_subCategory!] = validateLeaveCount;
      });
    }
  }

  int generateUniqueId() {
    final random = Random();

    int part1 = random.nextInt(9000) + 1000;
    int part2 = random.nextInt(900000) + 100000;

    String uniqueIdString = '$part1$part2';
    int uniqueId = int.parse(uniqueIdString);

    return uniqueId;
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile file = result.files.first;

      if (mounted) {
        setState(() {
          _selectedFileName = file.name;
        });
      }

      Uint8List? fileBytes;

      if (file.bytes != null) {
        fileBytes = file.bytes;
      } else if (file.path != null) {
        fileBytes = await File(file.path!).readAsBytes();
      }

      if (fileBytes != null) {
        if (_fileUrl != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File already uploaded'),
            ),
          );
          return;
        }
        final storageRef =
            FirebaseStorage.instance.ref().child('uploads/${file.name}');
        await storageRef.putData(fileBytes);
        String downloadUrl = await storageRef.getDownloadURL();

        if (mounted) {
          // Check again before updating the UI
          setState(() {
            _fileUrl = downloadUrl;
          });
        }
        
      } else {
        
      }
    } else {
      
    }
  }

  void _submitTicket() async {
    if(_isLoading) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _uid = user.uid;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_mainCategory == 'renumration' && _fileUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please upload a file before submitting.')),
        );
        return;
      }
      setState(() {
        _isLoading = true;
      });

      int ticketId = generateUniqueId();

      await FirebaseFirestore.instance.collection('tickets').add({
        'uid': _uid,
        'name': _name,
        'title': _title,
        'category': _category,
        'description': _description,
        'mainCategory': _mainCategory,
        'subCategory': _subCategory,
        'datesOfRequirement': _mainCategory == 'leaves'
            ? _selectedDates.map((date) => Timestamp.fromDate(date)).toList()
            : null,
        'status': _status,
        'fileUrl': _mainCategory == 'renumration' ? _fileUrl : null,
        'ticketId': ticketId,
        'attachments': _fileUrl != null ? [_fileUrl] : [],
        'isApproved': false,
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final leaveDoc = await FirebaseFirestore.instance
            .collection('leaveCounts')
            .doc(user.uid)
            .get();

        if (!leaveDoc.exists) {
          await FirebaseFirestore.instance
              .collection('leaveCounts')
              .doc(user.uid)
              .set({
            'casualLeaveCount': 28,
            'medicalLeaveCount': 28,
            'unpaidLeaveCount': 0,
            'uid': user.uid,
          });
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket Created Successfully')),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (ctx) => const UserTabs()),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickMultipleDates(BuildContext context) async {
    final DateTime firstDate = DateTime.now();
    final DateTime lastDate = firstDate.add(const Duration(days: 90));
    List<DateTime> tempSelectedDates = [];

    bool pickingDates = true;

    while (pickingDates) {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: firstDate,
        firstDate: firstDate,
        lastDate: lastDate,
        selectableDayPredicate: (date) {
          // Exclude weekends (Saturday and Sunday)
          return date.weekday != DateTime.saturday &&
              date.weekday != DateTime.sunday;
        },
      );

      if (pickedDate != null) {
        tempSelectedDates.add(pickedDate);
      } else {
        pickingDates = false; // Stop the loop if the user cancels.
      }
    }

    setState(() {
      _selectedDates = tempSelectedDates;
      _dateController.text = _selectedDates
          .map((d) => DateFormat('yyyy-MM-dd').format(d))
          .join(', ');
    });
  }

  int countValidLeaves(List<DateTime> selectedDates) {
    return selectedDates
        .where((date) =>
            date.weekday != DateTime.saturday &&
            date.weekday != DateTime.sunday)
        .length;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Ticket User'),
        backgroundColor: Colors.orange.shade400,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTextField('Name', (value) => _name = value),
                  const SizedBox(height: 16),
                  _buildTextField('Title', (value) => _title = value),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Description',
                    (value) => _description = value,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    'Main Category',
                    _mainCategory,
                    ['leaves', 'renumration'],
                    (value) => setState(() {
                      _mainCategory = value;
                      _subCategory = null;
                    }),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  if (_mainCategory == 'leaves') ...[
                    _buildDropdown(
                      'Leave Type',
                      _subCategory,
                      ['casual', 'medical', 'unpaid'],
                      (value) {
                        setState(() {
                          _subCategory = value!;
                          _selectedDates.clear();
                          _updateLeaveCounts();
                        });
                      },
                    ),
                    _buildCalendar(),
                    Text(
                      'Selected ${_subCategory ?? 'Leave'} count:${_leaveCounts[_subCategory ?? ''] ?? 0}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                  if (_mainCategory == 'renumration') ...[
                    _buildDropdown(
                      'renumration type',
                      _subCategory,
                      ['wifi', 'salary', 'other'],
                      (value) {
                        setState(() {
                          _subCategory = value!;
                        });
                      },
                    ),
                    _buildFilePicker(),
                  ],
                  const SizedBox(height: 20),
                  _isLoading ? const CircularProgressIndicator()
                 : ElevatedButton(
                    onPressed: _submitTicket,
                    child: const Text('Submit Ticket'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, FormFieldSetter<String> onSaved,
      {int maxLines = 1}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onSaved: onSaved,
      maxLines: maxLines,
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter $label' : null,
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select $label' : null,
    );
  }

  Widget _buildCalendar() {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(const Duration(days: 90)),
          focusedDay: DateTime.now(),
          selectedDayPredicate: (day) => _selectedDates.contains(day),
          calendarFormat: CalendarFormat.month,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              if (_selectedDates.contains(selectedDay)) {
                _selectedDates.remove(selectedDay);
              } else if (selectedDay.weekday != DateTime.saturday &&
                  selectedDay.weekday != DateTime.sunday) {
                _selectedDates.add(selectedDay);
              }
            });
            _updateLeaveCounts();
            _dateController.text = _selectedDates
                .map((d) => DateFormat('yyyy-MM-dd').format(d))
                .join(', ');
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _dateController,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Selected Dates',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildFilePicker() {
    return Column(
      children: [
        TextButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload File'),
        ),
        if (_selectedFileName != null)
          Text('Selected File: $_selectedFileName'),
      ],
    );
  }
}
