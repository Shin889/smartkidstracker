import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentRecords extends StatefulWidget {
  const StudentRecords({super.key});

  @override
  _StudentRecordsState createState() => _StudentRecordsState();
}

class _StudentRecordsState extends State<StudentRecords> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Student> studentRecords = [];
  String? userRole = 'admin'; 

  @override
  void initState() {
    super.initState();
    fetchStudentRecords(); // Fetch records from Firestore when the screen initializes
  }

  // Function to fetch student records from Firestore
  Future<void> fetchStudentRecords() async {
    try {
      print("Fetching student records...");
      QuerySnapshot snapshot = await _firestore.collection('confirmed_children').get();

      if (snapshot.docs.isEmpty) {
        print("No student records found.");
        setState(() {
          studentRecords = [];
        });
        return;
      }

      // Map the snapshot to a list of Student objects
      List<Student> fetchedRecords = snapshot.docs.map((doc) {
        return Student(
          name: '${doc['childName']}', // Assuming these fields exist
          section: userRole == 'admin' ? doc['section'] : 'N/A', // Show section for admin, hide for teacher
        );
      }).toList();

      setState(() {
        studentRecords = fetchedRecords;
        print('Fetched records: $studentRecords');
      });
    } catch (e) {
      print('Error fetching student records: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching student records: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: studentRecords.isEmpty
            ? Center(
                child: Text(
                  'No student records found.',
                  style: TextStyle(fontSize: 16.0),
                ),
              )
            : ListView.builder(
                itemCount: studentRecords.length,
                itemBuilder: (context, index) {
                  Student student = studentRecords[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          student.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        subtitle: userRole == 'admin'
                            ? Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'Section: ${student.section ?? 'N/A'}',
                                  style: TextStyle(fontSize: 14.0),
                                ),
                              )
                            : null,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class Student {
  final String name;
  final String? section;

  Student({
    required this.name,
    this.section,
  });
}
