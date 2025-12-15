import 'package:flutter/material.dart';
import 'package:mentalzen/screens/3-message_board/journal_entry_form.dart';
import 'package:mentalzen/services/authservice.dart';
import 'package:mentalzen/services/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentalzen/models/journal_entry.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen(this.authService, this.dbHelper, {super.key});

  final AuthService authService;
  final FirestoreHelper dbHelper;

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late String _email;

  late Stream<QuerySnapshot> _journalStream;

  final TextEditingController _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Tracks status of submitted async update request
  // Either 'ready', 'pending', 'complete', or 'error'
  String _sendingMessage = 'ready';

  @override
  void initState() {
    super.initState();

    _email = widget.authService.getEmail() ?? ''; // this should never be null

    _journalStream = widget.dbHelper.getJournalEntryStream(_email);
  }

  void _submitJournalForm() async {
    // Lock interface, prepare to send update
    setState(() {
      _sendingMessage = 'pending';
    });

    JournalEntry entry = JournalEntry(
      message: _messageController.text,
      userId: _email,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Send message and register function to update status on completion
    bool result = await widget.dbHelper.addJournalEntry(_email, entry);

    if (result) {
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
  }

  void _showJournalEntryForm({JournalEntry? journalEntry}) {
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
                child: JournalEntryForm(
                  widget.authService,
                  widget.dbHelper,
                  journalEntry: journalEntry,
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
    return Column(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child:
              // Journal entry stream
              StreamBuilder<QuerySnapshot>(
                stream: _journalStream,
                builder:
                    (
                      BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot,
                    ) {
                      if (snapshot.hasError) {
                        return const Text(
                          'Something went wrong',
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.w400,
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text(
                          'Loading',
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.w400,
                          ),
                        );
                      }

                      return ListView(
                        shrinkWrap: true,
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                              Map<String, dynamic> data =
                                  document.data()! as Map<String, dynamic>;
                              JournalEntry entry = JournalEntry.fromMap(data);

                              // Null/emptiness check
                              if (entry.message == null ||
                                  entry.userId == null ||
                                  entry.createdAt == null ||
                                  entry.updatedAt == null ||
                                  entry.message == '' ||
                                  entry.userId == '') {
                                return Container();
                              }

                              return ListTile(
                                title: Text(entry.message!),
                                subtitle: Text(
                                  // TODO: update this
                                  'Sent by ${entry.userId!} at ${entry.createdAt!.toString()}',
                                ),
                              );
                            })
                            .toList()
                            .cast(),
                      );
                    },
              ),
        ),

        SizedBox(height: 20.0),

        ElevatedButton.icon(
          onPressed: () => _showJournalEntryForm(),
          icon: const Icon(Icons.add),
          label: const Text('Add Journal Entry'),
        ),
      ],
    );
  }
}
