import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../controller/constants.dart';
import '../controller/controller.dart';
import '../model/student.dart';
import '../controller/shared.dart';
import 'constants.dart';
import 'shared.dart';

class AttendancePage extends StatefulWidget {
  final String section;
  final String role;

  const AttendancePage({
    super.key,
    required this.section,
    required this.role,
  });

  @override
  State<AttendancePage> createState() => _RfidTaggingState();
}

class _RfidTaggingState extends State<AttendancePage> {
  var firestoreController = FirestoreController();
  Student tappedStudent = Student(
      id: '', firstName: '', middleName: '', lastName: '', rfidNumber: '', section: '', email: '');
  String tappedType = '';
  String valData = '';
  String? rfidNumber;
  FocusNode? n;

  @override
  void initState() {
    super.initState();
    n = FocusNode();
    super.initState();
    NfcController(context).checkNfc();
  }

  Future<void> startNFCReading(Student student, String type) async {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      ValueNotifier<dynamic> result = ValueNotifier(null);
      Map<String, dynamic>? nfcData;
      setState(() {
        result.value = tag.data;
        nfcData = tag.data;
        String formattedString = nfcData!['nfca']['identifier'].join('-');
        firestoreController.handleRfidScan(
            context, student, formattedString, type);
        Navigator.pop(context);
        AttendanceSuccessSnackbar(context).showTaggedSnackbar();
        NfcManager.instance.stopSession();
      });
    });
  }

  Future<void> scanRfid(Student studentModel, String type) async {
    tappedStudent = studentModel;
    tappedType = type;
    NfcController(context).showNfcDialog(
      studentModel.firstName, 
      studentModel.middleName, 
      studentModel.lastName);
    startNFCReading(studentModel, type);
  }

  _buildTextComposer(Student student, String type) {
    valData = '';
    FocusScope.of(context).requestFocus(n);
    return KeyboardListener(
        focusNode: n!,
        onKeyEvent: (KeyEvent event) {
          if (event.runtimeType.toString() == 'KeyUpEvent') {
            String values;
            if (event.logicalKey.keyLabel == "Alt Left" ||
                event.logicalKey.keyLabel == "Enter") {
              int dec = int.parse(valData);
              String xx = dec.toRadixString(16);
              if (xx.length < 8) {
                values = '0$xx';
              } else {
                values = xx;
              }

              rfidNumber =
                  '${int.parse(values.substring(6, 8), radix: 16)}-${int.parse(values.substring(4, 6), radix: 16)}-${int.parse(values.substring(2, 4), radix: 16)}-${int.parse(values.substring(0, 2), radix: 16)}';
              firestoreController.handleRfidScan(
                  context, student, rfidNumber!, type);
              Navigator.pop(context);
              AttendanceSuccessSnackbar(context).showTaggedSnackbar();
            } else {
              valData += event.logicalKey.keyLabel;
            }
          }
        },
        child: Text(''));
  }

  void showTapInTapOutDialog(String student, Student studentModel) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(CONTROLLERCONSTANTS.nfc, size: CONTROLLERCONSTANTS.iconSize),
            ],
          ),
          content: Text(
            textAlign: TextAlign.center,
            'Hello $student. Please choose an action.',
            style: TextStyle(fontSize: 20),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.green),
                    ),
                    child:
                        Text('Tap In', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.of(context).pop();
                      scanRfid(studentModel, 'tap-in');
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.red),
                    ),
                    child:
                        Text('Tap Out', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.of(context).pop();
                      scanRfid(studentModel, 'tap-out');
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(ATTENDANCECONSTANTS.attendanceTitle)),
        body: Column(
          children: [
            _buildTextComposer(tappedStudent, tappedType),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestoreController.streamCollection('children'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ReturnLoading();
                  } else if (snapshot.hasError) {
                    return ReturnText(message: CONTROLLERCONSTANTS.errorText);
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return ReturnText(
                        message: CONTROLLERCONSTANTS.noStudentsText);
                  } else {
                    final students = firestoreController.getAllStudents(
                        snapshot.data!, widget.section);
                    return GridView.builder(
                      gridDelegate: CONTROLLERCONSTANTS.gridDelegate,
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return StudentCard(
                          student: student,
                          onTap: () =>
                              showTapInTapOutDialog(student.firstName, student),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ));
  }
} 