import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _appBarTitle = 'Home'; // Default title

  void _updateTitle(String title) {
    setState(() {
      _appBarTitle = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.orange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Text(_appBarTitle), // Use the dynamic title
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                print("Profile icon clicked");
              },
            ),
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                print("Help icon clicked");
              },
            ),
          ],
        ),
      ),
      drawer: _buildDrawer(),
      body: const Center(
        child: Text('Main Screen'),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.3)),
            child: const Text(
              'Menu',
              style: TextStyle(fontSize: 32, color: Colors.white),
            ),
          ),
          _buildDrawerItem('Announcement', () {
            _updateTitle('Announcement');
            // Navigate to Announcement screen
          }),
          _buildDrawerItem('Attendance Record', () {
            _updateTitle('Attendance Record');
            // Navigate to Attendance Record screen
          }),
          _buildDrawerItem('About', () {
            _updateTitle('About');
            // Navigate to About screen
          }),
          _buildDrawerItem('Authentication', () {
            _updateTitle('Authentication');
          }),
          _buildDrawerItem('Teacher Record', () {
            _updateTitle('Teacher Record');
          }),
          _buildDrawerItem('Student Record', () {
            _updateTitle('Student Record');
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Close the drawer
        onTap(); // Call the onTap function to update the title and navigate
      },
    );
  }
}
