import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'constants.dart';
import '../model/student.dart';
import 'shared.dart';

class NfcController {
  final BuildContext context;
  NfcController(this.context);

  void checkNfc() async {
    NFCAvailability availability = await FlutterNfcKit.nfcAvailability;
    if (availability == NFCAvailability.not_supported) {
      _showNotSupported();
    } else if (availability == NFCAvailability.disabled) {
      _enableNFC();
    } else {
      debugPrint("NFC is available");
    }
  }

  void _showNotSupported() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return NotSupportedDialog();
      },
    );
  }

  void _enableNFC() {
    showDialog(
      context: context,
      builder: (context) {
        return EnableNFC();
      },
    );
  }

  void showNfcDialog(String student, String middleName, String lastName) {
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
            'Hello $student. Please scan your card now.',
            style: TextStyle(fontSize: 20),
          ),
        );
      },
    );
  }

  void showRfidNotMatchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('RFID Not Match'),
          content: Text('The scanned RFID does not match any student records.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class FirestoreController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> streamCollection(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  List<Student> getAllStudents(QuerySnapshot snapshot, String section) {
    return snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['section'] == section;
    }).map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Student.fromMap(data, doc.id);
    }).toList();
  }

  Future<void> insertRfidNumber(String id, String rfid) async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('children').doc(id).update({
      'rfidNumber': rfid,
    });
  }

Future<void> recordAttendance(
    Student student, String type, String rfid) async {
  try {
    await FirebaseFirestore.instance.collection('attendance').add({
      'name': '${student.firstName} ${student.middleName} ${student.lastName}'.trim(),
      'section': student.section,
      'email': student.email,
      'rfidNumber': rfid,
      'attendance': type,
      'timestamp': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    debugPrint('Error inserting attendance: $e');
  }
}


  Future<void> handleRfidScan(
      BuildContext context, Student student, String rfid, String type) async {
    try {
      final querySnapshot = await _firestore
          .collection('children')
          .where('rfidNumber', isEqualTo: rfid)
          .get();

      if (querySnapshot.docs.isEmpty) {
        NfcController(context).showRfidNotMatchDialog();
      } else {
        await recordAttendance(student, type, rfid);
      }
    } catch (e) {
      debugPrint('Error handling RFID scan: $e');
    }
  }
}
