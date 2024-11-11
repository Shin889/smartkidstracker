import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  final int _limit = 20;
  
  final List<DocumentSnapshot> _historyRecords = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadHistory();
    }
  }

  Future<void> _loadHistory() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      Query query = _firestore
          .collection('history')
          .orderBy('timestamp', descending: true)
          .limit(_limit);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      QuerySnapshot snapshot = await query.get();
      
      if (snapshot.docs.isEmpty) {
        setState(() => _hasMore = false);
        return;
      }

      setState(() {
        _historyRecords.addAll(snapshot.docs);
        _lastDocument = snapshot.docs.last;
        _hasMore = snapshot.docs.length == _limit;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading history: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _archiveOldLogs() async {
    try {
      final DateTime oneMonthAgo = DateTime.now().subtract(Duration(days: 30));
      final WriteBatch batch = _firestore.batch();
      final QuerySnapshot snapshot = await _firestore
          .collection('history')
          .where('timestamp', isLessThan: Timestamp.fromDate(oneMonthAgo))
          .limit(500) // Firestore batch limit
          .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No old logs to archive')),
        );
        return;
      }

      // Archive to a separate collection before deletion
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        batch.set(_firestore.collection('archived_history').doc(doc.id), data);
        batch.delete(doc.reference);
      }

      await batch.commit();
      
      // Refresh the list
      setState(() {
        _historyRecords.clear();
        _lastDocument = null;
        _hasMore = true;
      });
      _loadHistory();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully archived ${snapshot.docs.length} logs')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error archiving logs: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _historyRecords.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _historyRecords.length) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final data = _historyRecords[index].data() as Map<String, dynamic>;
                final timestamp = (data['timestamp'] as Timestamp).toDate();

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(data['action'] ?? 'Unknown Action'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID: ${data['id']}'),
                        Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp)),
                      ],
                    ),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: data['status'] == 'Success' 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        data['status'] ?? 'Unknown',
                        style: TextStyle(
                          color: data['status'] == 'Success' 
                            ? Colors.green 
                            : Colors.red,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}