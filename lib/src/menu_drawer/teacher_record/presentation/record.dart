import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Teacher {
  final String name;
  final String? section;
  final String? phoneNumber;

  Teacher({
    required this.name,
    this.section,
    this.phoneNumber,
  });
}

class TeacherRecordScreen extends StatefulWidget {
  const TeacherRecordScreen({super.key});

  @override
  _TeacherRecordScreenState createState() => _TeacherRecordScreenState();
}

class _TeacherRecordScreenState extends State<TeacherRecordScreen> {
  List<Teacher> teacherRecords = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTeacherRecords(); // Fetch records from Firestore when the screen initializes
  }

  // Function to fetch teacher records from Firestore
  Future<void> fetchTeacherRecords() async {
    try {
      print("Fetching teacher records...");
      // Reference to the confirmed_teachers collection
      CollectionReference teachersCollection =
          FirebaseFirestore.instance.collection('confirmed_teachers');

      // Get the snapshot of the collection
      QuerySnapshot snapshot = await teachersCollection.get();

      if (snapshot.docs.isEmpty) {
        print("No teacher records found.");
        // Update the state with an empty list and set isLoading to false
        setState(() {
          teacherRecords = [];
          isLoading = false;
        });
        return;
      }

      // Map the snapshot to a list of Teacher objects
      List<Teacher> fetchedRecords = snapshot.docs.map((doc) {
        return Teacher(
          name: '${doc['firstName']} ${doc['lastName']}', // Concatenate first and last name
          section: doc['section']?.toString() ?? 'N/A',
          phoneNumber: doc['phoneNumber']?.toString() ?? 'N/A',
        );
      }).toList();

      // Update the state with the fetched records and set isLoading to false
      setState(() {
        teacherRecords = fetchedRecords;
        isLoading = false;
        print('Fetched records: $teacherRecords');
      });
    } catch (e) {
      print('Error fetching teacher records: $e');
      // Update the state with isLoading set to false
      setState(() {
        isLoading = false;
      });
      // Show a snackbar with the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching teacher records: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show a loader while data is being fetched
          : teacherRecords.isEmpty
              ? Center(child: Text('No teacher records found.'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: teacherRecords.length,
                        itemBuilder: (context, index) {
                          Teacher teacher = teacherRecords[index];
                          return ListTile(
                            title: Text(teacher.name),
                            subtitle: Text(
                                'Section: ${teacher.section ?? 'N/A'}, Phone: ${teacher.phoneNumber ?? 'N/A'}'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}