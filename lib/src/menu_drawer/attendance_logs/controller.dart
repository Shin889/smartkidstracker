import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> streamCollection(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  List<DocumentSnapshot> getLogs(
      QuerySnapshot snapshot, String email, String role, String section) {
    if (role == "teacher") {
      return snapshot.docs.where((doc) => doc['section'] == section).toList();
    } else if (role == "admin") {
      return snapshot.docs.toList();
    } else {
      return snapshot.docs.where((doc) => doc['email'] == email).toList();
    }
  }
}
