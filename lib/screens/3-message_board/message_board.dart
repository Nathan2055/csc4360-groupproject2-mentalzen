import 'package:flutter/material.dart';
import 'package:mentalzen/services/authservice.dart';
import 'package:mentalzen/services/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentalzen/models/chat_entry.dart';

class MessageBoard extends StatefulWidget {
  const MessageBoard(
    this.authService,
    this.dbHelper,
    this.messageBoard, {
    super.key,
  });

  final AuthService authService;
  final FirestoreHelper dbHelper;
  final String messageBoard;

  @override
  State<MessageBoard> createState() => _MessageBoardState();
}

class _MessageBoardState extends State<MessageBoard> {
  late String _email;

  late Stream<QuerySnapshot> _chatStream;

  final TextEditingController _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Tracks status of submitted async update request
  // Either 'ready', 'pending', 'complete', or 'error'
  String _sendingMessage = 'ready';

  @override
  void initState() {
    super.initState();

    _chatStream = widget.dbHelper.getChatStream(widget.messageBoard);
    _email = widget.authService.getEmail() ?? ''; // this should never be null
  }

  void _submitChatForm() async {
    // Lock interface, prepare to send update
    setState(() {
      _sendingMessage = 'pending';
    });

    ChatEntry message = ChatEntry(
      message: _messageController.text,
      userEmail: _email,
      createdAt: DateTime.now(),
    );

    // Send message and register function to update status on completion
    bool result = await widget.dbHelper.addChatEntry(
      widget.messageBoard,
      message,
    );

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child:
              // Chat message stream
              StreamBuilder<QuerySnapshot>(
                stream: _chatStream,
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
                              ChatEntry message = ChatEntry.fromMap(data);

                              // Null/emptiness check
                              if (message.message == null ||
                                  message.userEmail == null ||
                                  message.createdAt == null ||
                                  message.message == '' ||
                                  message.userEmail == '') {
                                return Container();
                              }

                              return ListTile(
                                title: Text(message.message!),
                                subtitle: Text(
                                  'Sent by ${message.userEmail!} at ${message.createdAt!.toString()}',
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

        // Chat message form
        Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 24.0,
            children: [
              // Username field
              TextFormField(
                enabled: (_sendingMessage == 'ready'),
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: 'Chat Message',
                  prefixIcon: const Icon(Icons.message),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              // Submit button
              ElevatedButton(
                onPressed: (_sendingMessage != 'ready')
                    ? null
                    : _submitChatForm,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text('Send Message')],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
