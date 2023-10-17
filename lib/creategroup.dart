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

import 'groupchat.dart';

class GroupCreateScreen extends StatefulWidget {
  final List<Map<String, dynamic>> allUsers;

  GroupCreateScreen({required this.allUsers});

  @override
  _GroupCreateScreenState createState() => _GroupCreateScreenState();
}

class _GroupCreateScreenState extends State<GroupCreateScreen> {
  List<Map<String, dynamic>> selectedUsers = [];
  TextEditingController groupNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Group"),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: groupNameController,
              decoration: InputDecoration(
                labelText: "Group Name",
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.allUsers.length,
              itemBuilder: (context, index) {
                final user = widget.allUsers[index];
                return ListTile(
                  title: Text(user['name']),
                  subtitle: Text(user['email']),
                  leading: Checkbox(
                    value: selectedUsers.contains(user),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selectedUsers.add(user);
                        } else {
                          selectedUsers.remove(user);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              createGroup(groupNameController.text, selectedUsers);
              // Navigate to the GroupChatScreen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => GroupChatScreen(
                    groupId: groupNameController
                        .text, // Use the group name as the group ID for simplicity
                  ),
                ),
              );
            },
            child: Text("Create Group and Chat"),
          ),
        ],
      ),
    );
  }
  // void createGroup(String groupName, List<Map<String, dynamic>> members) {
  //   final FirebaseAuth auth = FirebaseAuth.instance;
  //   final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //   // Generate a unique group ID
  //   String groupId = firestore.collection('groups').doc().id;

  //   // Create the group document
  //   firestore.collection('groups').doc(groupId).set({
  //     'name': groupName,
  //     'members': members.map((user) => user['uid']).toList(),
  //   });

  //   // Add the group ID to the user's list of groups
  //   auth.currentUser!.updateProfile(
  //     displayName: groupId,
  //   );

  //   // You can also set additional information like the group name in the user's document

  //   // Create a group chat message to welcome members
  //   firestore.collection('groups').doc(groupId).collection('chats').add({
  //     'sender': 'Admin',
  //     'message': 'Welcome to the group chat!',
  //     'timestamp': FieldValue.serverTimestamp(),
  //   });
  // }
  void createGroup(String groupName, List<Map<String, dynamic>> members) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Create a new group

    firestore.collection('groups').doc(groupName).set({
      'name': groupName,
      'members': members.map((user) => user['uid']).toList(),
      'membername': members.map((user) => user['name']).toList(),
    });

    // Add the group ID to the user's list of groups (you can customize this)
    auth.currentUser!.updateProfile(displayName: groupName);

    // Additional logic can be added here if needed

    // Create a group chat message to welcome members
    firestore.collection('groups').doc(groupName).collection('chats').add({
      'sender': 'Admin',
      'message': 'Welcome to the group chat!',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
