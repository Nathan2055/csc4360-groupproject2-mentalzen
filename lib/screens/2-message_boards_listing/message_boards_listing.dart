import 'package:flutter/material.dart';
import 'package:mentalzen/authservice.dart';
import 'package:mentalzen/models/firestore_helper.dart';
import 'package:mentalzen/screens/3-message_board/message_board.dart';

class MessageBoardsListing extends StatefulWidget {
  const MessageBoardsListing(this.authService, this.dbHelper, {super.key});

  final AuthService authService;
  final FirestoreHelper dbHelper;

  @override
  State<MessageBoardsListing> createState() => _MessageBoardsListingState();
}

class _MessageBoardsListingState extends State<MessageBoardsListing> {
  String _visibleBoard = '';

  void _displayBoard(String messageBoard) {
    setState(() {
      _visibleBoard = messageBoard;
    });
  }

  Column _createBoardCard(
    String title,
    Color color,
    IconData icon,
    String targetBoard,
  ) {
    String subtitle = '';
    return Column(
      children: [
        GestureDetector(
          onTap: () => _displayBoard(targetBoard),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: color,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () => _displayBoard(targetBoard),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, size: 32, color: Colors.white),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle != ''
                                ? const SizedBox(height: 4)
                                : Container(),
                            subtitle != ''
                                ? Text(
                                    subtitle,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 14,
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(64.0),
        child: (_visibleBoard == '')
            ? Column(
                spacing: 24.0,
                children: [
                  const Text(
                    'Message Boards',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  _createBoardCard(
                    'Games',
                    Colors.orange,
                    Icons.games,
                    'games',
                  ),
                  _createBoardCard(
                    'Business',
                    Colors.teal,
                    Icons.show_chart,
                    'business',
                  ),
                  _createBoardCard(
                    'Public Health',
                    Colors.pinkAccent,
                    Icons.health_and_safety,
                    'health',
                  ),
                  _createBoardCard(
                    'Study',
                    Colors.purple,
                    Icons.school,
                    'study',
                  ),
                ],
              )
            : MessageBoard(widget.authService, widget.dbHelper, _visibleBoard),
      ),
    );
  }
}
