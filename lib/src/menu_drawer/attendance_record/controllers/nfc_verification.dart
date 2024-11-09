import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

class NFCVerificationController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<void> recordHistory(String tagId, String action, {String status = 'Success'}) async {
    try {
      await _firestore.collection('history').add({
        'id': tagId,
        'timestamp': Timestamp.now(),
        'action': action,
        'status': status,
      });
    } catch (e) {
      print("Error recording history: $e");
    }
  }

  Future<Map<String, dynamic>?> scanAndVerifyTag() async {
    try {
      NFCTag tag = await FlutterNfcKit.poll(timeout: Duration(seconds: 10));
      
      // Read the NDEF message from the tag
      var response = await FlutterNfcKit.transceive("A2");
      String data = utf8.decode(response as List<int>);
      List<String> parts = data.split(',');
      
      if (parts.length == 3) {
        String tagId = parts[2];
        
        // Verify against Firestore records
        var doc = await _firestore.collection('ndef_record').doc(tagId).get();
        
        if (doc.exists) {
          await recordHistory(tagId, 'Tag Verification', status: 'Success');
          return doc.data() as Map<String, dynamic>;
        } else {
          await recordHistory(tagId, 'Tag Verification', status: 'Failed - Tag Not Found');
          return null;
        }
      }
      return null;
    } catch (e) {
      print("Error during NFC verification: $e");
      return null;
    } finally {
      await FlutterNfcKit.finish();
    }
  }
}