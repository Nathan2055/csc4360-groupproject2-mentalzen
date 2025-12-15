import 'package:flutter/material.dart';
import 'package:mentalzen/services/authservice.dart';
import 'package:mentalzen/services/firestore_helper.dart';
import 'package:mentalzen/models/reminder_config.dart';
import 'package:mentalzen/screens/4-settings_screen/reminder_form.dart';
import 'package:mentalzen/screens/4-settings_screen/update_password_form.dart';
import 'package:mentalzen/screens/4-settings_screen/update_display_name_form.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen(this.authService, this.dbHelper, {super.key});

  final AuthService authService;
  final FirestoreHelper dbHelper;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _formatReminderTypes(List<String> types) {
    return types.map((t) => t[0].toUpperCase() + t.substring(1)).join(', ');
  }

  String _formatDaysOfWeek(List<int> days) {
    const dayNames = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };
    return days.map((d) => dayNames[d] ?? '').join(', ');
  }

  Future<void> _toggleReminder(String reminderId, bool currentValue) async {
    // Get the reminder first
    final remindersStream = widget.dbHelper.getUserReminders(
      widget.authService.getEmail() ?? '',
    );
    final reminders = await remindersStream.first;
    final reminder = reminders.firstWhere((r) => r.id == reminderId);

    // Update with toggled value
    final updatedReminder = ReminderConfig(
      id: reminder.id,
      userId: reminder.userId,
      types: reminder.types,
      time: reminder.time,
      daysOfWeek: reminder.daysOfWeek,
      isEnabled: !currentValue,
      createdAt: reminder.createdAt,
      updatedAt: DateTime.now(),
    );

    final success = await widget.dbHelper.updateReminder(
      widget.authService.getEmail() ?? '',
      reminderId,
      updatedReminder,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !currentValue ? 'Reminder enabled' : 'Reminder disabled',
          ),
        ),
      );
    }
  }

  Future<void> _deleteReminder(String reminderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await widget.dbHelper.deleteReminder(
        widget.authService.getEmail() ?? '',
        reminderId,
      );
      if (success && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Reminder deleted')));
      }
    }
  }

  void _showReminderForm({ReminderConfig? reminder}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: ReminderForm(
                  widget.authService,
                  widget.dbHelper,
                  reminder: reminder,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Reminders Section
          const Text(
            'Wellness Reminders',
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showReminderForm(),
            icon: const Icon(Icons.add),
            label: const Text('Add Reminder'),
          ),
          const SizedBox(height: 20),
          StreamBuilder<List<ReminderConfig>>(
            stream: widget.dbHelper.getUserReminders(
              widget.authService.getEmail() ?? '',
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No reminders set. Add one to get started!');
              }

              return Column(
                children: snapshot.data!.map((reminder) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(
                        '${reminder.time} - ${_formatReminderTypes(reminder.types)}',
                      ),
                      subtitle: Text(
                        '${_formatDaysOfWeek(reminder.daysOfWeek)}${reminder.isEnabled ? '' : ' (Disabled)'}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: reminder.isEnabled,
                            onChanged: (value) => _toggleReminder(
                              reminder.id,
                              reminder.isEnabled,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                _showReminderForm(reminder: reminder),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteReminder(reminder.id),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 40),

          // Update Display Name Section
          const Text(
            'Update Display Name',
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 20),
          UpdateDisplayNameForm(widget.authService, widget.dbHelper),
          const SizedBox(height: 40),

          // Update Password Section
          const Text(
            'Update Password',
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 20),
          UpdatePasswordForm(widget.authService, widget.dbHelper),
          const SizedBox(height: 40),

          // Logout Section
          const Text(
            'Log out',
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: widget.authService.logout,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('Log out')],
            ),
          ),
        ],
      ),
    );
  }
}
