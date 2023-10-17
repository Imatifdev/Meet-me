import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'creategroup.dart';
import 'member_chat_home.dart';
import 'groupchat.dart';

class GroupListScreen extends StatefulWidget {
  @override
  _GroupListScreenState createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> allUsers = [];
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    setStatus("Online");
    fetchAllUsers();
  }

  void setStatus(String status) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      "status": status,
    });
  }

  // String chatRoomId(String user1 ) {
  //   if (user1[0].toLowerCase().codeUnits[0] >
  //       user2.toLowerCase().codeUnits[0]) {
  //     return "$user1$user2";
  //   } else {
  //     return "$user2$user1";
  //   }
  // }

  Future<void> fetchAllUsers() async {
    try {
      var querySnapshot = await _firestore.collection('users').get();
      setState(() {
        allUsers = querySnapshot.docs.map((doc) {
          Map<String, dynamic> userData = doc.data();
          userData['uid'] = doc.id;
          return userData;
        }).toList();
      });

      for (var user in allUsers) {
        if (user.containsKey('profilePictures')) {
          String downloadURL = await FirebaseStorage.instance
              .ref(user['profilePictures'])
              .getDownloadURL();
          user['profilePictureURL'] = downloadURL;
        }
      }
    } catch (error) {
      print("Error fetching users: $error");
    }
  }

  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });

    String searchText = _search.text.trim();
    if (searchText.isNotEmpty) {
      try {
        var querySnapshot = await _firestore
            .collection('users')
            .where("name", isEqualTo: searchText)
            .get();

        setState(() {
          if (querySnapshot.docs.isNotEmpty) {
            userMap = querySnapshot.docs[0].data();
          } else {
            userMap = null;
          }
          isLoading = false;
        });
      } catch (error) {
        setState(() {
          userMap = null;
          isLoading = false;
        });
        print("Error searching user: $error");
      }
    } else {
      setState(() {
        userMap = null;
        isLoading = false;
      });
    }
  }

  void createGroup() {
    // Navigate to the GroupCreateScreen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GroupCreateScreen(allUsers: allUsers),
      ),
    );
  }

  void showgroups() {
    // Navigate to the GroupCreateScreen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GroupListScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.person),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (ctx) => GroupCreateScreen(
                                allUsers: allUsers,
                              )));
                },
                icon: Icon(Icons.group_add_rounded),
              )
            ],
          )
        ],
        title: Text('Chats'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('groups')
            .where('members', arrayContains: _auth.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final groups = snapshot.data!.docs;
          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              final groupName = group['name'] as String;

              return ListTile(
                title: Text(groupName),
                onTap: () {
                  // String roomId = chatRoomId(
                  //   _auth.currentUser!.displayName! * 8
                  //   //  userMap!['uid'],
                  // );

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => GroupChatScreen(groupId: groupName),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
