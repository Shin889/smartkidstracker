import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

class NFCReadScreen extends StatefulWidget {
  const NFCReadScreen({super.key});

  @override
  _NFCReadScreenState createState() => _NFCReadScreenState();
}

class _NFCReadScreenState extends State<NFCReadScreen> {
  bool _isNFCSupported = false;
  bool _isNFCEnabled = false;
  String _statusMessage = "Checking NFC availability...";

  @override
  void initState() {
    super.initState();
    _checkNFC();
  }

  Future<void> _checkNFC() async {
    try {
      final nfcStatus = await FlutterNfcKit.nfcAvailability;
      setState(() {
        _isNFCSupported = nfcStatus == NFCAvailability.available;
        _isNFCEnabled = nfcStatus != NFCAvailability.disabled;
        _statusMessage = _isNFCSupported
            ? _isNFCEnabled
                ? "NFC is available and enabled on this device."
                : "NFC is available but disabled. Please enable NFC in settings."
            : "NFC is not supported on this device.";
      });
    } catch (e) {
      setState(() {
        _isNFCSupported = false;
        _isNFCEnabled = false;
        _statusMessage = "Error checking NFC: $e";
      });
      _showErrorDialog("NFC Error", "Could not check NFC support: $e");
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("NFC Check"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkNFC,
              child: Text("Recheck NFC Status"),
            ),
          ],
        ),
      ),
    );
  }
}
