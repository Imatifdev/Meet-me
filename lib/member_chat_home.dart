import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meetly/showgroups.dart';

import 'chat_room.dart';
import 'creategroup.dart';

class MemberChatHomeWidget extends StatefulWidget {
  const MemberChatHomeWidget({super.key});

  @override
  MemberChatHomeWidgetState createState() => MemberChatHomeWidgetState();
}

class MemberChatHomeWidgetState extends State<MemberChatHomeWidget> {
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> allUsers = [];

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

  // String chatRoomId(String user1, String user2) {
  //   if (user1[0].toLowerCase().codeUnits[0] >
  //       user2.toLowerCase().codeUnits[0]) {
  //     return "$user1$user2";
  //   } else {
  //     return "$user2$user1";
  //   }
  // }

  // Future<String> createChatRoom() async {
  //   // Generate a unique chat room ID using Firebase
  //   final chatRoomDocRef = await _firestore.collection('chatRooms').add({});
  //   return chatRoomDocRef.id;
  // }

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (ctx) => UserChatPage("12")));
              },
              icon: Icon(Icons.telegram))
        ],
      ),
      body: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: allUsers.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> userData = allUsers[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 1, color: Colors.grey)),
              child: ListTile(
                onTap: () {
                  String roomId = chatRoomId(
                    _auth.currentUser!.uid!,
                    userData['uid'] * 7,
                  );

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatRoom(
                        chatRoomId: roomId,
                        userMap: userData,
                      ),
                    ),
                  );
                },
                leading: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(width: 1),
                  ),
                  child: CircleAvatar(
                    backgroundColor:
                        Colors.blue, // Change the background color as desired
                    child: Text(
                      userData['name']
                          [0], // Display the first character of the user's name
                      style: TextStyle(
                        color: Colors.white, // Change the text color as desired
                        fontSize: 24, // Adjust the font size as desired
                      ),
                    ),
                  ),
                ),
                title: Text(
                  userData['name'],
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(userData['email']),
                trailing: const Icon(
                  CupertinoIcons.right_chevron,
                  color: Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class UserChatPage extends StatelessWidget {
  final String chatRoomId;

  UserChatPage(this.chatRoomId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Screen'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chatroom')
            .doc(chatRoomId)
            .collection('chats')
            .orderBy('time', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          final chatData = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chatData.length,
            itemBuilder: (context, index) {
              final message = chatData[index]['message'];
              final timestamp = chatData[index]['time'] as Timestamp;
              final date = timestamp.toDate();
              final formattedTime = '${date.hour}:${date.minute}';

              return ListTile(
                title: Text(message),
                subtitle: Text(formattedTime),
              );
            },
          );
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';

// class MemberChatHomeWidget extends StatefulWidget {
//   const MemberChatHomeWidget({Key? key});

//   @override
//   MemberChatHomeWidgetState createState() => MemberChatHomeWidgetState();
// }

// class MemberChatHomeWidgetState extends State<MemberChatHomeWidget> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   List<Map<String, dynamic>> allUsers = [];
//   Map<String, dynamic>? userMap;
//   bool isLoading = false;
//   final TextEditingController _search = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     fetchAllUsers();
//   }

//   Future<void> fetchAllUsers() async {
//     try {
//       var querySnapshot = await _firestore.collection('users').get();
//       setState(() {
//         allUsers = querySnapshot.docs.map((doc) {
//           Map<String, dynamic> userData = doc.data();
//           userData['uid'] = doc.id;
//           return userData;
//         }).toList();
//       });

//       for (var user in allUsers) {
//         if (user.containsKey('profilePictures')) {
//           String downloadURL = await FirebaseStorage.instance
//               .ref(user['profilePictures'])
//               .getDownloadURL();
//           user['profilePictureURL'] = downloadURL;
//         }
//       }
//     } catch (error) {
//       print("Error fetching users: $error");
//     }
//   }

//   void onSearch() async {
//     setState(() {
//       isLoading = true;
//     });

//     String searchText = _search.text.trim();
//     if (searchText.isNotEmpty) {
//       try {
//         var querySnapshot = await _firestore
//             .collection('users')
//             .where("name", isEqualTo: searchText)
//             .get();

//         setState(() {
//           if (querySnapshot.docs.isNotEmpty) {
//             userMap = querySnapshot.docs[0].data();
//           } else {
//             userMap = null;
//           }
//           isLoading = false;
//         });
//       } catch (error) {
//         setState(() {
//           userMap = null;
//           isLoading = false;
//         });
//         print("Error searching user: $error");
//       }
//     } else {
//       setState(() {
//         userMap = null;
//         isLoading = false;
//       });
//     }
//   }

//   void startChatWithUser(Map<String, dynamic> userData) {
//     // Check if a chat room already exists between the current user and the selected user
//     final currentUserUid = _auth.currentUser!.uid;
//     final selectedUserUid = userData['uid'];

//     _firestore
//         .collection('chats')
//         .where('users', arrayContainsAny: [currentUserUid, selectedUserUid])
//         .get()
//         .then((querySnapshot) {
//           if (querySnapshot.docs.isNotEmpty) {
//             // Chat room already exists, navigate to it
//             final chatRoomId = querySnapshot.docs[0].id;
//             Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (_) => ChatRoom(
//                   chatData: userData,
//                 ),
//               ),
//             );
//           } else {
//             // Chat room doesn't exist, create a new one
//             final chatRoomId =
//                 createNewChatRoom(currentUserUid, selectedUserUid);
//             Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (_) => ChatRoom(
//                   chatData: userData,
//                 ),
//               ),
//             );
//           }
//         });
//   }

//   String createNewChatRoom(String user1, String user2) {
//     final chatRoomId =
//         user1.compareTo(user2) < 0 ? '$user1$user2' : '$user2$user1';

//     // Create a new chat room document
//     _firestore.collection('chats').doc(chatRoomId).set({
//       'users': [user1, user2],
//     });

//     return chatRoomId;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Chat with Users"),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _search,
//               decoration: InputDecoration(
//                 hintText: "Search for users",
//                 suffixIcon: IconButton(
//                   icon: Icon(Icons.search),
//                   onPressed: onSearch,
//                 ),
//               ),
//             ),
//           ),
//           isLoading
//               ? CircularProgressIndicator()
//               : userMap != null
//                   ? ListTile(
//                       leading: CircleAvatar(
//                         backgroundImage:
//                             NetworkImage(userMap!['profilePictureURL'] ?? ''),
//                       ),
//                       title: Text(userMap!['name']),
//                       subtitle: Text(userMap!['email']),
//                       trailing: ElevatedButton(
//                         onPressed: () {
//                           startChatWithUser(userMap!);
//                         },
//                         child: Text("Chat"),
//                       ),
//                     )
//                   : SizedBox(),
//           Expanded(
//             child: ListView.builder(
//               itemCount: allUsers.length,
//               itemBuilder: (context, index) {
//                 Map<String, dynamic> userData = allUsers[index];
//                 return ListTile(
//                   leading: CircleAvatar(
//                     backgroundImage:
//                         NetworkImage(userData['profilePictureURL'] ?? ''),
//                   ),
//                   title: Text(userData['name']),
//                   subtitle: Text(userData['email']),
//                   trailing: ElevatedButton(
//                     onPressed: () {
//                       startChatWithUser(userData);
//                     },
//                     child: Text("Chat"),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ChatRoom extends StatelessWidget {
//   final Map<String, dynamic> chatData;

//   ChatRoom({required this.chatData});

//   final TextEditingController _message = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   void onSendMessage() async {
//     if (_message.text.isNotEmpty) {
//       Map<String, dynamic> message = {
//         "user": _firestore.doc("users/${_auth.currentUser!.uid}"),
//         "chat": _firestore.doc("chats/${chatData['chatId']}"),
//         "text": _message.text,
//         "timestamp": FieldValue.serverTimestamp(),
//       };

//       await _firestore.collection('messages').add(message);
//       _message.clear();

//       // Update chat's last message information
//       await _firestore.collection('chats').doc(chatData['chatId']).update({
//         "lastMessage": _message.text,
//         "lastMessageTime": FieldValue.serverTimestamp(),
//         "lastMessageSentBy": _firestore.doc("users/${_auth.currentUser!.uid}"),
//         "lastMessageSeenBy": [],
//         "isMessageUnread": true,
//       });
//     } else {
//       print("Enter Some Text");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: Text(
//       //       "Chat with ${chatData['users'][0]} and ${chatData['users'][1]}"),
//       // ),
//       body: Column(
//         children: [
//           Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//             stream: _firestore
//                 .collection('chats')
//                 .where('messages')
//                 .orderBy('timestamp')
//                 .snapshots(),
//             builder:
//                 (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Center(child: CircularProgressIndicator());
//               }

//               if (snapshot.hasError) {
//                 return Center(child: Text('Error loading messages.'));
//               }

//               if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                 return Center(child: Text('No messages yet.'));
//               }

//               return ListView.builder(
//                 itemCount: snapshot.data!.docs.length,
//                 itemBuilder: (context, index) {
//                   Map<String, dynamic> messageData =
//                       snapshot.data!.docs[index].data() as Map<String, dynamic>;
//                   String message = messageData['text'];
//                   String sentByUser = messageData['user'];

//                   // Retrieve the user's data from Firestore
//                   return FutureBuilder<DocumentSnapshot>(
//                     future:
//                         _firestore.collection('users').doc(sentByUser).get(),
//                     builder: (BuildContext context,
//                         AsyncSnapshot<DocumentSnapshot> userSnapshot) {
//                       if (userSnapshot.connectionState ==
//                           ConnectionState.done) {
//                         if (userSnapshot.hasError) {
//                           return Text('Error: ${userSnapshot.error}');
//                         } else if (userSnapshot.hasData) {
//                           var userData =
//                               userSnapshot.data!.data() as Map<String, dynamic>;
//                           String userName = userData['name'];

//                           return ListTile(
//                             title: Text(
//                               message,
//                               style: TextStyle(
//                                 color: sentByUser == _auth.currentUser!.uid
//                                     ? Colors.blue
//                                     : Colors.black,
//                               ),
//                             ),
//                             subtitle: Text(
//                               sentByUser == _auth.currentUser!.uid
//                                   ? "You"
//                                   : userName,
//                             ),
//                           );
//                         }
//                       }
//                       return CircularProgressIndicator(); // Loading user data
//                     },
//                   );
//                 },
//               );
//             },
//           )),
//           Container(
//             padding: EdgeInsets.all(8),
//             color: Colors.white,
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _message,
//                     decoration: InputDecoration(
//                       hintText: "Type a message",
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: onSendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
