import 'package:flutter/material.dart';
import 'package:mentalzen/services/authservice.dart';
import 'package:mentalzen/services/firestore_helper.dart';
import 'package:mentalzen/models/journal_entry.dart';

class JournalEntryForm extends StatefulWidget {
  const JournalEntryForm(
    this.authService,
    this.dbHelper, {
    this.journalEntry,
    super.key,
  });

  final AuthService authService;
  final FirestoreHelper dbHelper;

  // If provided, we're editing; otherwise, creating
  final JournalEntry? journalEntry;

  @override
  State<JournalEntryForm> createState() => _JournalEntryFormState();
}

class _JournalEntryFormState extends State<JournalEntryForm> {
  final TextEditingController _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Tracks status of submitted async update request
  // Either 'ready', 'pending', 'complete', or 'error'
  String _sendingMessage = 'ready';

  @override
  void initState() {
    super.initState();
    if (widget.journalEntry != null) {
      // Editing existing journal entry
      final journalEntry = widget.journalEntry!;

      // Load existing journal entry into text editor
      _messageController.text = journalEntry.message ?? '';
    } else {
      // Creating new journal entry
      _messageController.text = '';
    }
  }

  Future<void> _saveJournalEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Lock interface, prepare to send update
    setState(() {
      _sendingMessage = 'pending';
    });

    final DateTime now = DateTime.now();

    final JournalEntry entry = JournalEntry(
      message: _messageController.text,
      userId: widget.authService.getEmail() ?? '',
      createdAt: widget.journalEntry?.createdAt ?? now,
      updatedAt: now,
    );

    bool success;
    if (widget.journalEntry != null) {
      success = await widget.dbHelper.updateJournalEntry(
        widget.authService.getEmail() ?? '',
        widget.journalEntry!.id!,
        entry,
      );
    } else {
      success = await widget.dbHelper.addJournalEntry(
        widget.authService.getEmail() ?? '',
        entry,
      );
    }

    if (success) {
      setState(() {
        _sendingMessage = 'complete';
      });
    } else {
      setState(() {
        _sendingMessage = 'error';
      });
    }

    // Wait for update to commit and then update status
    while (_sendingMessage != 'ready') {
      if (_sendingMessage == 'complete') {
        // Reload entire interface upon completion to avoid desyncs
        setState(() {
          _messageController.text = '';
          _sendingMessage = 'ready';
        });
      } else if (_sendingMessage == 'error') {
        // TODO: send error up the chain
      }
    }

    if (success) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.journalEntry != null
                  ? 'Journal entry updated successfully'
                  : 'Journal entry created successfully',
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save journal entry')),
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
          // Message field
          TextFormField(
            enabled: (_sendingMessage == 'ready'),
            controller: _messageController,
            decoration: InputDecoration(
              labelText: 'Journal Entry',
              prefixIcon: const Icon(Icons.message),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Save and Cancel buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: (_sendingMessage != 'ready')
                    ? null
                    : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: (_sendingMessage != 'ready')
                    ? null
                    : _saveJournalEntry,
                child: Text(
                  widget.journalEntry != null
                      ? 'Update Journal Entry'
                      : 'Create Journal Entry',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
