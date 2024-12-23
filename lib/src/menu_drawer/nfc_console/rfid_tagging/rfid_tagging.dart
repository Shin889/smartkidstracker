import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:smartkidstracker/src/menu_drawer/nfc_console/controller/controller.dart';
import 'package:smartkidstracker/src/menu_drawer/nfc_console/rfid_tagging/constants.dart';
import '../controller/constants.dart';
import '../model/student.dart';
import '../controller/shared.dart';
import 'shared.dart';

class NFCTagging extends StatefulWidget {
  final String section;
  final String role;

  const NFCTagging({
    super.key,
    required this.section,
    required this.role,
  });

  @override
  State<NFCTagging> createState() => _NFCTaggingState();
}

class _NFCTaggingState extends State<NFCTagging> {
  var firestoreController = FirestoreController();
  String valData = '';
  FocusNode? n;
  String? rfidNumber;
  String tappedStudent = '';
  String focusSelected = 'back';

  @override
  void initState() {
    n = FocusNode();
    super.initState();
    NfcController(context).checkNfc();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed
    n!.dispose();
    super.dispose();
  }

  Future<void> startNFCReading(String id) async {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      ValueNotifier<dynamic> result = ValueNotifier(null);
      Map<String, dynamic>? nfcData;
      setState(() {
        result.value = tag.data;
        nfcData = tag.data;
        String formattedString = nfcData!['nfca']['identifier'].join('-');
        firestoreController.insertRfidNumber(id, formattedString);
        Navigator.pop(context);
        RfidSuccessSnackbar(context).showTaggedSnackbar();
        NfcManager.instance.stopSession();
      });
    });
  }

  void scanRfid(BuildContext context, Student student) async {
    tappedStudent = student.id;
    NfcController(context).showNfcDialog(student.firstName, student.middleName, student.lastName);
    startNFCReading(student.id);
  }

  _buildTextComposer(String id) {
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
            
              firestoreController.insertRfidNumber(id, rfidNumber!);
              Navigator.pop(context);
              RfidSuccessSnackbar(context).showTaggedSnackbar();
            } else {
              valData += event.logicalKey.keyLabel;
            }
          }
        },
        child: Text(''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(NFCTAGGINGCONSTANTS.rfidTitle)),
      body: Column(
        children: [
          _buildTextComposer(tappedStudent),
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
                        onTap: () => scanRfid(context, student),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
