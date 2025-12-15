import 'package:flutter/material.dart';
import 'package:mentalzen/services/authservice.dart';
import 'package:mentalzen/services/firestore_helper.dart';
import 'package:mentalzen/screens/3-message_board/message_board.dart';
import 'package:mentalzen/screens/mood_tracker_screen.dart';
import 'package:mentalzen/screens/resources_screen.dart';

class MessageBoardsListing extends StatefulWidget {
  const MessageBoardsListing(this.authService, this.dbHelper, {super.key, this.resetState});

  final AuthService authService;
  final FirestoreHelper dbHelper;
  final VoidCallback? resetState;

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
            constraints: const BoxConstraints(
              minHeight: 100, // Increased minimum height
            ),
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
                        child: Icon(icon, size: 36, color: Colors.white),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.visible,
                              softWrap: true,
                            ),
                            subtitle != ''
                                ? const SizedBox(height: 8)
                                : Container(),
                            subtitle != ''
                                ? Text(
                                    subtitle,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 15,
                                    ),
                                    overflow: TextOverflow.visible,
                                    softWrap: true,
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 24,
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

  Widget _getScreenForBoard(String board) {
    switch (board) {
      case 'mood_tracker':
        return MoodTrackerScreen(widget.authService, widget.dbHelper);
      case 'resources':
        return ResourcesScreen(widget.authService, widget.dbHelper);
      case 'journal':
      case 'insights':
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.construction, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Coming Soon!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'This feature is under development',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _displayBoard(''),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        );
      default:
        return MessageBoard(widget.authService, widget.dbHelper, _visibleBoard);
    }
  }

  @override
  void didUpdateWidget(MessageBoardsListing oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset to dashboard when widget updates
    if (widget.resetState != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _visibleBoard = '';
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: (_visibleBoard == '')
            ? Column(
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Mental Zen Dashboard',
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track your wellness journey',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _createBoardCard(
                    'Mood Tracker',
                    Colors.blue,
                    Icons.mood,
                    'mood_tracker',
                  ),
                  const SizedBox(height: 16),
                  _createBoardCard(
                    'Journal',
                    Colors.teal,
                    Icons.book,
                    'journal',
                  ),
                  const SizedBox(height: 16),
                  _createBoardCard(
                    'Mindfulness Resources',
                    Colors.purple,
                    Icons.self_improvement,
                    'resources',
                  ),
                  const SizedBox(height: 16),
                  _createBoardCard(
                    'Insights & Analytics',
                    Colors.orange,
                    Icons.analytics,
                    'insights',
                  ),
                  const SizedBox(height: 16),
                ],
              )
            : _getScreenForBoard(_visibleBoard),
      ),
    );
  }
}
