import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<Map<String, dynamic>?> getUserDetails() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  return userDoc.data();
}

Future<List<Map<String, dynamic>>> getAllChildren() async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('children')
      .get();

  return querySnapshot.docs.map((doc) => doc.data()).toList();
}

Future<List<Map<String, dynamic>>> getChildrenInSection(String section) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('children')
      .where('section', isEqualTo: section)
      .get();

  return querySnapshot.docs.map((doc) => doc.data()).toList();
}

class StudentRecords extends StatefulWidget {
  const StudentRecords({super.key});

  @override
  _StudentRecordsState createState() => _StudentRecordsState();
}

class _StudentRecordsState extends State<StudentRecords> {
  late Future<List<Map<String, dynamic>>> _childrenFuture;
  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredChildren = [];

  @override
  void initState() {
    super.initState();
    _childrenFuture = _loadChildren();
  }

  Future<List<Map<String, dynamic>>> _loadChildren() async {
    final userDetails = await getUserDetails();
    if (userDetails == null) {
      throw Exception('User not logged in.');
    }

    if (userDetails['role'] == 'Admin') {
      // Admin can see all children
      return getAllChildren();
    } else if (userDetails['role'] == 'Teacher') {
      // Teachers see children in their section
      final section = userDetails['section'];
      return getChildrenInSection(section);
    } else {
      throw Exception('Not authorized or no role assigned.');
    }
  }

  void _filterChildren(String query, List<Map<String, dynamic>> children) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredChildren = children
          .where((child) =>
              '${child['firstName']} ${child['middleName']} ${child['lastName'] ?? ''}'
                  .toLowerCase()
                  .contains(_searchQuery))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _childrenFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No children found.'));
          }

          final children = snapshot.data!..sort((a, b) {
            return (a['firstName'] ?? '').compareTo(b['firstName'] ?? '');
          });

          if (_searchQuery.isEmpty) {
            _filteredChildren = children;
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  onChanged: (query) => _filterChildren(query, children),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search by name...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredChildren.length,
                    itemBuilder: (context, index) {
                      final child = _filteredChildren[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          title: Text(
                            '${child['firstName'] ?? ''} ${child['middleName'] ?? ''} ${child['lastName'] ?? ''}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Section: ${child['section'] ?? 'N/A'}'),
                              Text('Email: ${child['email'] ?? 'N/A'}'),
                              Text('Phone: ${child['phoneNumber'] ?? 'N/A'}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
