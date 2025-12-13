import 'package:flutter/material.dart';
import 'package:mentalzen/models/reminder_config.dart';
import 'package:mentalzen/services/firestore_helper.dart';

class ReminderForm extends StatefulWidget {
  const ReminderForm(this.dbHelper, this.userEmail, {this.reminder, super.key});

  final FirestoreHelper dbHelper;
  final String userEmail;
  final ReminderConfig?
  reminder; // If provided, we're editing; otherwise, creating

  @override
  State<ReminderForm> createState() => _ReminderFormState();
}

class _ReminderFormState extends State<ReminderForm> {
  final _formKey = GlobalKey<FormState>();
  late TimeOfDay _selectedTime;
  final List<String> _availableTypes = ['workout', 'water', 'diet', 'snack'];
  final Map<String, bool> _selectedTypes = {
    'workout': false,
    'water': false,
    'diet': false,
    'snack': false,
  };
  final Map<int, bool> _selectedDays = {
    1: false, // Monday
    2: false, // Tuesday
    3: false, // Wednesday
    4: false, // Thursday
    5: false, // Friday
    6: false, // Saturday
    7: false, // Sunday
  };
  bool _isEnabled = true;

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      // Editing existing reminder
      final reminder = widget.reminder!;
      final timeParts = reminder.time.split(':');
      _selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
      for (final type in reminder.types) {
        _selectedTypes[type] = true;
      }
      for (final day in reminder.daysOfWeek) {
        _selectedDays[day] = true;
      }
      _isEnabled = reminder.isEnabled;
    } else {
      // Creating new reminder
      _selectedTime = TimeOfDay.now();
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _getDayName(int day) {
    const days = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };
    return days[day] ?? '';
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if at least one type is selected
    final selectedTypesList = _selectedTypes.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    if (selectedTypesList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one reminder type'),
        ),
      );
      return;
    }

    // Check if at least one day is selected
    final selectedDaysList = _selectedDays.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    if (selectedDaysList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day')),
      );
      return;
    }

    final timeString = _formatTime(_selectedTime);
    final now = DateTime.now();

    final reminder = ReminderConfig(
      id: widget.reminder?.id ?? '',
      userId: widget.userEmail,
      types: selectedTypesList,
      time: timeString,
      daysOfWeek: selectedDaysList,
      isEnabled: _isEnabled,
      createdAt: widget.reminder?.createdAt ?? now,
      updatedAt: now,
    );

    bool success;
    if (widget.reminder != null) {
      // Update existing reminder
      success = await widget.dbHelper.updateReminder(
        widget.userEmail,
        widget.reminder!.id,
        reminder,
      );
    } else {
      // Create new reminder
      success = await widget.dbHelper.createReminder(
        widget.userEmail,
        reminder,
      );
    }

    if (success) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.reminder != null
                  ? 'Reminder updated successfully'
                  : 'Reminder created successfully',
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save reminder')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time picker
          ListTile(
            title: const Text('Time'),
            subtitle: Text(_formatTime(_selectedTime)),
            trailing: const Icon(Icons.access_time),
            onTap: _selectTime,
          ),
          const Divider(),

          // Reminder types
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Reminder Types',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ..._availableTypes.map((type) {
            return CheckboxListTile(
              title: Text(type[0].toUpperCase() + type.substring(1)),
              value: _selectedTypes[type],
              onChanged: (bool? value) {
                setState(() {
                  _selectedTypes[type] = value ?? false;
                });
              },
            );
          }),

          const Divider(),

          // Days of week
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Days of Week',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ..._selectedDays.entries.map((entry) {
            return CheckboxListTile(
              title: Text(_getDayName(entry.key)),
              value: entry.value,
              onChanged: (bool? value) {
                setState(() {
                  _selectedDays[entry.key] = value ?? false;
                });
              },
            );
          }),

          const Divider(),

          // Enable/Disable toggle
          SwitchListTile(
            title: const Text('Enable Reminder'),
            value: _isEnabled,
            onChanged: (bool value) {
              setState(() {
                _isEnabled = value;
              });
            },
          ),

          const SizedBox(height: 24),

          // Save and Cancel buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _saveReminder,
                child: Text(widget.reminder != null ? 'Update' : 'Create'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
