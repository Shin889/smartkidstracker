import 'package:flutter/material.dart';

class CONTROLLERCONSTANTS {
  static const String errorText = 'Error on loading students';
  static const String noStudentsText = 'No students found';
  static const String warningText = 'Warning';
  static const String notSupportedText = 'NFC is not supported on this device.';
  static const String confirmText = 'Confirm';
  static const String nfcDisabled = 'NFC Disabled';
  static const String enableText = 'Enable NFC to use this feature.';
  static const String notNow = 'Not Now';
  static const String enable = 'Enable';
  static const String androidIntent = 'android.settings.NFC_SETTINGS';
  static const IconData nfc = Icons.nfc;
  static const double iconSize = 40;
  static const TextStyle rfidTextStyle =
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  static const SliverGridDelegateWithFixedCrossAxisCount gridDelegate =
      SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 3 / 2,
  );
  static void navigatorPop(BuildContext context) {
    Navigator.of(context).pop();
  }
}
