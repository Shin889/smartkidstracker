import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class Announcement extends StatefulWidget {
  final String selectedRole;

  const Announcement({super.key, required this.selectedRole});

  @override
  _AnnouncementState createState() => _AnnouncementState();
}

class _AnnouncementState extends State<Announcement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final FirebaseMessaging _firebaseMessaging;

  @override
  void initState() {
    super.initState();
    _initializeFirebaseMessaging();
  }

  Future<void> _initializeFirebaseMessaging() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      
      String? token = await _firebaseMessaging.getToken();
      print("FCM Token: $token");

      // You can send this token to your server here
    } else {
      print('User declined or has not accepted permission');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received message: ${message.notification?.title}");
      // Handle the received message
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Opened app from notification: ${message.notification?.title}");
      // Handle notification when the app is opened from a notification
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPostsList(),
      floatingActionButton: _buildFloatingActionButton(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Menu'),
            ),
            ListTile(
              title: const Text('Announcement'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ]
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (widget.selectedRole == 'teacher' || widget.selectedRole =='admin') {
      return FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () => _showPostCreationDialog(context),
        child: const Icon(Icons.add),
      );
    }
    return null;
  }

  Widget _buildPostsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('posts').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final posts = snapshot.data!.docs;
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) => _buildPostCard(posts[index]),
        );
      },
    );
  }

  Widget _buildPostCard(QueryDocumentSnapshot post) {
    final postData = post.data() as Map<String, dynamic>;
    final Timestamp timestamp = postData['createdAt'] as Timestamp;
    final DateTime postDate = timestamp.toDate();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(postData['authorName'] ?? 'Anonymous'),
            subtitle: Text(
              '${postDate.toLocal()}',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          if (postData['mediaUrl'] != null) Image.network(postData['mediaUrl']),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(postData['content'] ?? 'No Content'),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: _buildLikeButton(post.id, postData['likes'] ?? []),
          ),
        ],
      ),
    );
  }

  Widget? _buildLikeButton(String postId, List<dynamic> likes) {
    final currentUserId = _auth.currentUser?.uid;
    final isLiked = likes.contains(currentUserId);

    return IconButton(
      icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: Colors.blueAccent),
      onPressed: () => _toggleLike(postId, currentUserId, isLiked),
    );
  }

  Future<void> _toggleLike(String postId, String? currentUserId, bool isLiked) async {
    if (currentUserId == null) return;

    final newLikes = isLiked
        ? FieldValue.arrayRemove([currentUserId])
        : FieldValue.arrayUnion([currentUserId]);
    await _firestore.collection('posts').doc(postId).update({'likes': newLikes});
  }

  void _showPostCreationDialog(BuildContext context) {
    final contentController = TextEditingController();
    final titleController = TextEditingController();
    String? selectedGroup;
    File? selectedMedia;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create New Post'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: contentController,
                      decoration: const InputDecoration(labelText: 'Content'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(setState, (media) {
                        setState(() {
                          selectedMedia = media;
                        });
                      }),
                      icon: const Icon(Icons.photo),
                      label: const Text('Add Photo/Video'),
                    ),
                    if (selectedMedia != null) ...[
                      const SizedBox(height: 10),
                      Text('Selected media: ${selectedMedia!.path.split('/').last}'),
                    ] else ...[
                      const SizedBox(height: 10),
                      const Text('No media selected'),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Post'),
                  onPressed: () async {
                    await _createPost(
                      title: titleController.text,
                      content: contentController.text,
                      mediaFile: selectedMedia,
                    );
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _pickImage(StateSetter setState, void Function(File?) updateMedia) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      updateMedia(File(pickedFile.path));
    }
  }

  Future<void> _createPost({
  required String title,
  required String content,
  File? mediaFile,
}) async {
  try {
    final user = _auth.currentUser;
    if (user != null) {
      String? mediaUrl;

      if (mediaFile != null) {
        mediaUrl = await _uploadMedia(mediaFile);
        if (mediaUrl == null) {
          print('Error: Media URL is null');
          return;
        }
      }

      await _firestore.collection('posts').add({
        'title': title,
        'content': content,
        'authorId': user.uid,
        'authorName': user.displayName,
        'mediaUrl': mediaUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': [],
      });
    }
  } catch (e) {
    print('Error creating post: $e');
  }
}


 Future<String?> _uploadMedia(File mediaFile) async {
  try {
    final user = _auth.currentUser;
    if (user != null) {
      final fileName = mediaFile.path.split('/').last;
      final storageRef = FirebaseStorage.instance.ref().child('posts/$fileName');
      await storageRef.putFile(mediaFile);
      return await storageRef.getDownloadURL();
    } else {
      print('Error: User is not authenticated.');
      return null;
    }
  } catch (e) {
    print('Error uploading media: $e');
    return null;
  }
}
}