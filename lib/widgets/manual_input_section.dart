import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';

class ManualInputSection extends StatefulWidget {
  final void Function(DateTime dateTime) onRecordAdded;
  final StorageService storage;

  const ManualInputSection({
    super.key,
    required this.onRecordAdded,
    required this.storage,
  });

  @override
  State<ManualInputSection> createState() => _ManualInputSectionState();
}

class _ManualInputSectionState extends State<ManualInputSection> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    _selectedTime = TimeOfDay(hour: now.hour, minute: now.minute);
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _submit() {
    final dt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    widget.onRecordAdded(dt);
    setState(() {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay(hour: 12, minute: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '手動で記録',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B9CB3),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const SizedBox(
                    width: 100,
                    child: Text('日付', style: TextStyle(color: Color(0xFFE6EDF3))),
                  ),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickDate,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE6EDF3),
                        side: const BorderSide(color: Color(0xFF2D3A4D)),
                      ),
                      child: Text(DateFormat('yyyy/MM/dd').format(_selectedDate)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const SizedBox(
                    width: 100,
                    child: Text('時刻', style: TextStyle(color: Color(0xFFE6EDF3))),
                  ),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickTime,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE6EDF3),
                        side: const BorderSide(color: Color(0xFF2D3A4D)),
                      ),
                      child: Text(_selectedTime.format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _submit,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: const Color(0xFFE6EDF3),
                    side: const BorderSide(color: Color(0xFF2D3A4D)),
                  ),
                  child: const Text('記録を追加'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
