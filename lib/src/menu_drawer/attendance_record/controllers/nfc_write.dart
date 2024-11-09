import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:ndef/ndef.dart';
import 'package:smartkidstracker/src/menu_drawer/attendance_record/controllers/nfc_verification.dart';

class NFCWriteScreen extends StatefulWidget {
  const NFCWriteScreen({super.key});

  @override
  _NFCWriteScreenState createState() => _NFCWriteScreenState();
}

class _NFCWriteScreenState extends State<NFCWriteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sectionController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _nfcController = NFCVerificationController();

  bool _isWriting = false;
  String? _statusMessage;

  String generateUniqueId() {
    final random = Random();
    return '${DateTime.now().millisecondsSinceEpoch}-${random.nextInt(9999).toString().padLeft(4, '0')}';
  }

  Future<void> _writeToNFC() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isWriting = true;
      _statusMessage = null;
    });

    String uniqueId = generateUniqueId();
    String childName = _nameController.text.trim();
    String childSection = _sectionController.text.trim();

    try {
      // Check if NFC is available
      if (await FlutterNfcKit.nfcAvailability == NFCAvailability.not_supported) {
        throw 'NFC not supported on this device.';
      }

      // Poll for NFC tag
      NFCTag tag = await FlutterNfcKit.poll(timeout: Duration(seconds: 10));
      final payload = "$childName,$childSection,$uniqueId";

      // Create and write NDEF message as text record
      final ndefRecord = NDEFRecord(
        type: Uint8List.fromList('T'.codeUnits), // 'T' for Text record
        payload: Uint8List.fromList([0x02, ...'en'.codeUnits, ...payload.codeUnits]),
      );
      await FlutterNfcKit.writeNDEFRecords([ndefRecord]);

      // Store in Firestore
      await _firestore.collection('ndef_record').doc(uniqueId).set({
        'name': childName,
        'section': childSection,
        'id': uniqueId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Record history
      await _nfcController.recordHistory(uniqueId, 'Tag Write');

      setState(() {
        _isWriting = false;
        _statusMessage = "Write operation successful!";
      });
    } catch (error) {
      setState(() {
        _isWriting = false;
        _statusMessage = "Error: ${error.toString()}";
      });
      await _nfcController.recordHistory(
        uniqueId, 
        'Tag Write', 
        status: 'Failed - ${error.toString()}'
      );
    } finally {
      await FlutterNfcKit.finish();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('NFC Write')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Child Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => 
                  value?.isEmpty ?? true ? 'Please enter the child\'s name' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _sectionController,
                decoration: InputDecoration(
                  labelText: 'Section',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter the section' : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isWriting ? null : _writeToNFC,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
                child: _isWriting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Write to NFC Tag'),
              ),
              if (_statusMessage != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _statusMessage!,
                    style: TextStyle(
                      color: _statusMessage!.contains('Error') 
                        ? Colors.red 
                        : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
