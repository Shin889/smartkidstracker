import 'package:nfc_manager/nfc_manager.dart';

// NFC Scanner class
class NFCScanner {
  Future<String?> scanNfcSticker() async {
    try {
      String? uid;
      await NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        uid = _extractNfcUid(tag);
        NfcManager.instance.stopSession();
      });
      return uid;
    } catch (e) {
      print('Error scanning NFC sticker: $e');
      return null;
    }
  }

  String _extractNfcUid(NfcTag tag) {
    final nfcId = tag.data['nfca']?['identifier'];
    if (nfcId != null) {
      return nfcId.map((e) => e.toRadixString(16).padLeft(2, '0')).join('').toUpperCase();
    }
    return '';
  }
}

class StudentRecord {
  final String name;
  final String nfcUid;

  StudentRecord({required this.name, required this.nfcUid});
}

List<StudentRecord> students = [
  StudentRecord(name: '', nfcUid: ''),
  StudentRecord(name: '', nfcUid: ''),
];

// Function to match NFC UID to student
StudentRecord? findStudentByNfcId(String nfcId) {
  try {
    return students.firstWhere(
      (student) => student.nfcUid == nfcId,
      orElse: () => StudentRecord(name: '', nfcUid: ''),
    );
  } catch (e) {
    print('Error finding student by NFC ID: $e');
    return null;
  }
}
