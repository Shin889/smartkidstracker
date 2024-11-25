import 'package:flutter/material.dart';
import 'package:smartkidstracker/src/menu_drawer/nfc_console/attendance/attendance.dart';
import 'package:smartkidstracker/src/menu_drawer/nfc_console/console/constants.dart';
import 'package:smartkidstracker/src/menu_drawer/nfc_console/rfid_tagging/rfid_tagging.dart';
import 'shared.dart';

class ConsolePage extends StatefulWidget {
  final String section;
  final String role;

  const ConsolePage({
    super.key,
    required this.section,
    required this.role,
  });

  @override
  State<ConsolePage> createState() => _ConsolePageState();
}

class _ConsolePageState extends State<ConsolePage> {
  void navigateToRfidTagging(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              RfidTagging(section: widget.section, role: widget.role)),
    );
  }

  void navigateToAttendance(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              AttendancePage(section: widget.section, role: widget.role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NFCIcon(),
            const SizedBox(height: NFCCONTANTS.sizedBoxHeight),
            TypeButton(
              text: NFCCONTANTS.rfidText,
              onPressed: () => navigateToRfidTagging(context),
              color: NFCCONTANTS.buttonColor,
            ),
            TypeButton(
              text: NFCCONTANTS.attendanceText,
              onPressed: () => navigateToAttendance(context),
              color: NFCCONTANTS.buttonColor,
            ),
          ],
        ),
      ),
    );
  }
}
