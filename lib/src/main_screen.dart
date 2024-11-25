import 'package:flutter/material.dart';
import 'package:smartkidstracker/src/general_acc/views/signin_screen.dart';
import 'package:smartkidstracker/src/menu_drawer/account_authentication/pg_acc.dart';
import 'package:smartkidstracker/src/menu_drawer/account_authentication/teacher_acc.dart';
import 'package:smartkidstracker/src/menu_drawer/attendance_logs/attendance_logs.dart';
import 'package:smartkidstracker/src/menu_drawer/attendance_record/presentation/record.dart';
import 'package:smartkidstracker/src/menu_drawer/nfc_console/console/nfc_console.dart';
import 'package:smartkidstracker/src/menu_drawer/student_record/presentation/record.dart';
import 'package:smartkidstracker/src/menu_drawer/teacher_record/presentation/record.dart';
import 'package:smartkidstracker/src/menu_drawer/announcement/announcement.dart';
import 'package:smartkidstracker/src/minor_deets/about_screen.dart';
import 'package:smartkidstracker/src/widgets/appbar/profile/user_profile.dart';
import 'package:smartkidstracker/src/minor_deets/help_screen.dart';

class MainScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String section;
  final String role;
  final String email;

  const MainScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.section,
    required this.role,
    required this.email,
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
      if (widget.role == 'admin') ...[
        const TeacherAcc(),
        const StudentRecords(),
        const TeacherRecordScreen(),
      ] else if (widget.role == 'teacher') ...[
        const StudentRecords(),
        PgAccScreen(
            childName: 'Child Name',
            userRole: widget.role,
            schoolName: '',
            childSection: '',
            childSchool: '',
            email: '',
            phone: ''),
      ],
      AttendanceScreen(
        userRole: '',
        section: '',
      ),
      ConsolePage(
        section: widget.section,
        role: widget.role,
      ),
      AttendanceLogs(
        section: widget.section,
        role: widget.role,
        email: widget.email,
      ),
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
      child: Column(
        children: <Widget>[
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.blue,
              image: DecorationImage(
                image: AssetImage('assets/image/drawer_header_bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smartkids Tracker',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '${widget.firstName} ${widget.lastName}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        widget.role,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                _buildDrawerItem(
                  icon: Icons.announcement,
                  title: 'Announcement',
                  index: 0,
                ),
                ..._buildRoleSpecificItems(),
                _buildDrawerItem(
                  icon: Icons.calendar_today,
                  title: 'Attendance Record',
                  index: _screens.length - 4,
                ),
                _buildDrawerItem(
                  icon: Icons.nfc,
                  title: 'NFC Console',
                  index: _screens.length - 3,
                ),
                _buildDrawerItem(
                  icon: Icons.note,
                  title: 'RFID LOGS',
                  index: _screens.length - 2,
                ),
                _buildDrawerItem(
                  icon: Icons.info,
                  title: 'About',
                  index: _screens.length - 1,
                ),
                Divider(),
                _buildDrawerItem(
                  icon: Icons.exit_to_app,
                  title: 'Sign Out',
                  onTap: () => _showSignoutConfirmationDialog(context),
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRoleSpecificItems() {
    switch (widget.role) {
      case 'admin':
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
      case 'teacher':
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
      case 'parent or guardian':
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
    Color color = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color, fontSize: 16),
      ),
      onTap: () {
        if (onTap != null) {
          onTap();
        } else if (index != null) {
          _onItemTapped(index, title);
          Navigator.pop(context); // Close the drawer
        }
      },
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}
