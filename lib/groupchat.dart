import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meetly/showgroups.dart';

import 'chat_room.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class GroupChatScreen extends StatefulWidget {
  final String groupId;

  GroupChatScreen({required this.groupId});

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Chat'),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              _showGroupInfo();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('groups')
                  .doc(widget.groupId)
                  .collection('chats')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final messages = snapshot.data!.docs;

                List<Widget> messageWidgets = [];
                for (var message in messages) {
                  final messageText = message['message'];
                  final messageSender = message['sender'];

                  final currentUser = _auth.currentUser;

                  final messageWidget = MessageWidget(
                    text: messageText,
                    isCurrentUser: messageSender == currentUser!.uid,
                  );

                  messageWidgets.add(messageWidget);
                }

                // Scroll to the end of the chat when new messages arrive
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                });

                return ListView(
                  controller: _scrollController,
                  reverse: false,
                  children: messageWidgets,
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.image),
                  onPressed: () {
                    _pickImage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage() async {
    final currentUser = _auth.currentUser;
    final messageText = _messageController.text.trim();
    DocumentReference userref =
        _firestore.collection('users').doc(_auth.currentUser!.uid);

    if (messageText.isNotEmpty) {
      await _firestore
          .collection('groups')
          .doc(widget.groupId)
          .collection('chats')
          .add({
        'seenby': [userref],
        'message': messageText,
        'sender': currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      await _uploadImage(imageFile);
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    final currentUser = _auth.currentUser;

    // Generate a unique message ID for the image
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();

    // Upload the image to Firebase Storage
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('group_images')
        .child('$messageId.jpg');
    await storageRef.putFile(imageFile);

    // Get the download URL of the uploaded image
    final imageUrl = await storageRef.getDownloadURL();

    // Send the image message to Firestore
    await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .collection('chats')
        .doc(messageId)
        .set({
      'message': imageUrl,
      'sender': currentUser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'type':
          'image', // Add a type field to distinguish images from text messages
    });
  }

  void _showGroupInfo() {
    // Fetch group information from Firestore
    _firestore
        .collection('groups')
        .doc(widget.groupId)
        .get()
        .then((groupSnapshot) {
      if (groupSnapshot.exists) {
        final groupName = groupSnapshot['name'] as String;
        final members = groupSnapshot['members'] as List<dynamic>;

        // Build the member list as a comma-separated string
        final memberIds = members.cast<String>();
        final memberList = memberIds.join(", ");

        // Create and show the group info dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Group Info: $groupName'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Members: $memberList'),
                  Text('Number of Members: ${members.length}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      }
    });
  }
}

class MessageWidget extends StatelessWidget {
  final String text;
  final bool isCurrentUser;
  final String? messageType;

  MessageWidget(
      {required this.text, required this.isCurrentUser, this.messageType});

  @override
  Widget build(BuildContext context) {
    final alignment =
        isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isCurrentUser ? Colors.blue : Colors.green;

    return Container(
      margin: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          if (messageType == 'image') // Check if the message is an image
            Container(
              child: Image.network(text), // Display the image
              width: 200, // Set the desired width for image previews
              height: 200, // Set the desired height for image previews
            )
          else
            Container(
              padding: EdgeInsets.all(8.0),
              color: color,
              child: Text(
                text,
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
