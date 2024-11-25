import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:smartkidstracker/src/menu_drawer/nfc_console/controller/controller.dart';
import 'package:smartkidstracker/src/menu_drawer/nfc_console/rfid_tagging/constants.dart';
import '../controller/constants.dart';
import '../model/student.dart';
import '../controller/shared.dart';
import 'shared.dart';

class RfidTagging extends StatefulWidget {
  final String section;
  final String role;

  const RfidTagging({
    super.key,
    required this.section,
    required this.role,
  });

  @override
  State<RfidTagging> createState() => _RfidTaggingState();
}

class _RfidTaggingState extends State<RfidTagging> {
  var firestoreController = FirestoreController();

  @override
  void initState() {
    super.initState();
    NfcController(context).checkNfc();
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
    NfcController(context).showNfcDialog(student.name);
    startNFCReading(student.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(RFIDTAGGINGCONSTANTS.rfidTitle)),
        body: StreamBuilder<QuerySnapshot>(
          stream: firestoreController.streamCollection('children'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ReturnLoading();
            } else if (snapshot.hasError) {
              return ReturnText(message: CONTROLLERCONSTANTS.errorText);
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return ReturnText(message: CONTROLLERCONSTANTS.noStudentsText);
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
        ));
  }
}
