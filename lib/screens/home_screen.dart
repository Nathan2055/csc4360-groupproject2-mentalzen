import 'package:flutter/material.dart';
import 'package:mentalzen/authservice.dart';
import 'package:mentalzen/models/firestore_helper.dart';
import 'package:mentalzen/screens/2-message_boards_listing/message_boards_listing.dart';
import 'package:mentalzen/screens/4-profile_screen/profile_screen.dart';
import 'package:mentalzen/screens/5-settings_screen/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen(this.authService, this.dbHelper, {super.key});

  final AuthService authService;
  final FirestoreHelper dbHelper;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AppBar _homeScreenAppBar;

  late Column _homeColumn;

  String _visibleScreen = 'home';

  @override
  void initState() {
    super.initState();

    _buildHomeScreenAppBar();
    _buildHomeColumn();
  }

  void _buildHomeScreenAppBar() {
    setState(() {
      _homeScreenAppBar = AppBar(
        title: const Text('Firebase Chat App'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Home',
            onPressed: () {
              setState(() {
                _visibleScreen = 'home';
                _buildHomeColumn();
              });
            },
          ),

          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () {
              setState(() {
                _visibleScreen = 'profile';
                _buildHomeColumn();
              });
            },
          ),

          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              setState(() {
                _visibleScreen = 'settings';
                _buildHomeColumn();
              });
            },
          ),
        ],
      );
    });
  }

  void _buildHomeColumn() {
    setState(() {
      _homeColumn = Column(
        children: [
          (_visibleScreen == 'home')
              ? MessageBoardsListing(widget.authService, widget.dbHelper)
              : Container(),
          (_visibleScreen == 'profile')
              ? ProfileScreen(widget.authService, widget.dbHelper)
              : Container(),
          (_visibleScreen == 'settings')
              ? SettingsScreen(widget.authService, widget.dbHelper)
              : Container(),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _homeScreenAppBar,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(64.0),
          child: _homeColumn,
        ),
      ),
    );
  }
}
