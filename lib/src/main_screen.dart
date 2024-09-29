import 'package:flutter/material.dart';
import 'package:smartkidstracker/src/general_acc/presentation/signin_screen.dart';
import 'package:smartkidstracker/src/menu_drawer/account_authentication/pg_acc.dart';
import 'package:smartkidstracker/src/menu_drawer/account_authentication/teacher_acc.dart';
import 'package:smartkidstracker/src/menu_drawer/attendance_record/presentation/record.dart';
import 'package:smartkidstracker/src/menu_drawer/student_record/presentation/record.dart';
import 'package:smartkidstracker/src/menu_drawer/teacher_record/presentation/record.dart';
import 'package:smartkidstracker/src/menu_drawer/announcement/announcement.dart';
import 'package:smartkidstracker/src/minor_deets/about_screen.dart';
import 'package:smartkidstracker/src/widgets/appbar/profile/userProfile.dart';
import 'package:smartkidstracker/src/minor_deets/help_screen.dart';

class MainScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String section;
  final String role;

  const MainScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.section,
    required this.role,
  });

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String _appBarTitle = 'Announcement'; // Default title

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _initializeScreens();
  }

  void _initializeScreens() {
  _screens = [
    Announcement(selectedRole: widget.role),
    if (widget.role == 'Admin') ...[
      const TeacherAcc(),
      const StudentRecords(),
      const TeacherRecordScreen(),
    ] else if (widget.role == 'Teacher') ...[
      const StudentRecords(),
      PgAccScreen(childName: 'Child Name', userRole: widget.role, schoolName: '', section: '',),
    ],
    const AttendanceScreen(),
    const AboutScreen(),
  ];
}

  void _onItemTapped(int index, String title) {
    setState(() {
      _selectedIndex = index;
      _appBarTitle = title;
    });
  }

  void _showSignoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sign out'),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfilePage(
                    firstName: widget.firstName,
                    lastName: widget.lastName,
                    section: widget.section,
                    role: widget.role,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpScreen()),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: _screens[_selectedIndex],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.3)),
            child: const Text(
              'Smartkids Tracker',
              style: TextStyle(fontSize: 32, color: Colors.white),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.announcement,
            title: 'Announcement',
            index: 0,
          ),
          ..._buildRoleSpecificItems(),
          _buildDrawerItem(
            icon: Icons.calendar_today,
            title: 'Attendance Record',
            index: _screens.length - 2,
          ),
          _buildDrawerItem(
            icon: Icons.info,
            title: 'About',
            index: _screens.length - 1,
          ),
          _buildDrawerItem(
            icon: Icons.exit_to_app,
            title: 'Sign Out',
            onTap: () => _showSignoutConfirmationDialog(context),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRoleSpecificItems() {
    switch (widget.role) {
      case 'Admin':
        return [
          _buildDrawerItem(
            icon: Icons.lock,
            title: 'Teacher Authentication',
            index: 1,
          ),
          _buildDrawerItem(
            icon: Icons.school,
            title: 'Student Record',
            index: 2,
          ),
          _buildDrawerItem(
            icon: Icons.person,
            title: 'Teacher Record',
            index: 3,
          ),
        ];
      case 'Teacher':
        return [
          _buildDrawerItem(
            icon: Icons.lock,
            title: 'Child Authentication',
            index: 2,
          ),
          _buildDrawerItem(
            icon: Icons.school,
            title: 'Student Record',
            index: 1,
          ),
        ];
      case 'Parent or Guardian':
        return [
          _buildDrawerItem(
            icon: Icons.child_care,
            title: 'Child Information',
            index: 1,
          ),
        ];
      default:
        return [];
    }
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    int? index,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        if (onTap != null) {
          onTap();
        } else if (index != null) {
          _onItemTapped(index, title);
          Navigator.pop(context); // Close the drawer
        }
      },
    );
  }
}