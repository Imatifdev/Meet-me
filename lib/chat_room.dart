// ignore_for_file: must_be_immutable, body_might_complete_normally_catch_error

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ChatRoom extends StatelessWidget {
  final Map<String, dynamic> userMap;
  final String chatRoomId;

  ChatRoom({super.key, required this.chatRoomId, required this.userMap});

  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  File? imageFile;

  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future uploadImage() async {
    String fileName = const Uuid().v1();
    int status = 1;

    await _firestore
        .collection('chatroom')
        .doc(chatRoomId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendby": _auth.currentUser!.displayName,
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });

    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl});

      print(imageUrl);
    }
  }

  // void onSendMessage() async {
  //   if (_message.text.isNotEmpty) {
  //     Map<String, dynamic> messages = {
  //       "users": [
  //         _auth.currentUser!.uid,
  //         userMap['uid'],
  //       ],
  //       "user_a": _auth.currentUser!.uid,
  //       "user_b": userMap['uid'],
  //       "sendby": _auth.currentUser!.displayName,
  //       "message": _message.text,
  //       "type": "text",
  //       "time": FieldValue.serverTimestamp(),
  //     };

  //     _message.clear();
  //     await _firestore
  //         .collection('chatroom')
  //         .doc(chatRoomId)
  //         .collection('chats')
  //         .add(messages);
  //   } else {
  //     print("Enter Some Text");
  //   }
  // }
  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      DocumentReference userARef =
          _firestore.collection('users').doc(_auth.currentUser!.uid);
      DocumentReference userBRef =
          _firestore.collection('users').doc(userMap['uid']);

      Map<String, dynamic> messages = {
        "user_a": userARef,
        "user_b": userBRef,
        "sendby": _auth.currentUser!.displayName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();
      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .add(messages);
    } else {
      print("Enter Some Text");
    }
  }

  Widget messages(Size size, Map<String, dynamic> map, BuildContext context) {
    return map['type'] == "text"
        ? Container(
            width: size.width - 100,
            alignment: map['sendby'] == _auth.currentUser!.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: map['sendby'] == _auth.currentUser!.displayName
                    ? Colors.green
                    : Colors.red,
              ),
              child: Text(
                map['message'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          )
        : Container(
            height: size.height / 2.5,
            width: size.width,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            alignment: map['sendby'] == _auth.currentUser!.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ShowImage(
                    imageUrl: map['message'],
                  ),
                ),
              ),
              child: Container(
                height: size.height / 2.5,
                width: size.width / 2,
                decoration: BoxDecoration(border: Border.all()),
                alignment: map['message'] != "" ? null : Alignment.center,
                child: map['message'] != ""
                    ? Image.network(
                        map['message'],
                        fit: BoxFit.cover,
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          contentPadding: const EdgeInsets.all(0),
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Text(userMap['name']),
          subtitle: Text(userMap['status']),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chatroom')
                  .doc(chatRoomId)
                  .collection('chats')
                  .orderBy("time", descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading messages.'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> map = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    return messages(size, map, context);
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: AutoNewLineTextFormField(
                    controller: _message,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {
                    getImage();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: onSendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AutoNewLineTextFormField extends StatefulWidget {
  final TextEditingController controller;

  AutoNewLineTextFormField({required this.controller});

  @override
  _AutoNewLineTextFormFieldState createState() =>
      _AutoNewLineTextFormFieldState();
}

class _AutoNewLineTextFormFieldState extends State<AutoNewLineTextFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.multiline,
      maxLines: null, // Set maxLines to null to allow multiple lines.
      decoration: InputDecoration(
        labelText: 'Enter text',
      ),
      onChanged: (text) {
        if (text.length > 0 && text.endsWith(' ')) {
          // Automatically add a new line when a space character is entered
          widget.controller.text += '\n';
          widget.controller.selection = TextSelection.fromPosition(
              TextPosition(offset: widget.controller.text.length));
        }
      },
    );
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  ShowImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: InteractiveViewer(
            child: Image.network(imageUrl),
          ),
        ),
      ),
    );
  }
}
// ignore_for_file: must_be_immutable, body_might_complete_normally_catch_error

// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:uuid/uuid.dart';

// class ChatRoom extends StatelessWidget {
//   final Map<String, dynamic> userMap;
//   final String chatRoomId;

//   ChatRoom({super.key, required this.chatRoomId, required this.userMap});

//   final TextEditingController _message = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   File? imageFile;

//   Future getImage() async {
//     ImagePicker _picker = ImagePicker();

//     await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
//       if (xFile != null) {
//         imageFile = File(xFile.path);
//         uploadImage();
//       }
//     });
//   }

//   Future uploadImage() async {
//     String fileName = const Uuid().v1();
//     int status = 1;

//     await _firestore
//         .collection('chatroom')
//         .doc(chatRoomId)
//         .collection('chats')
//         .doc(fileName)
//         .set({
//       "sendby": _auth.currentUser!.displayName,
//       "message": "",
//       "type": "img",
//       "time": FieldValue.serverTimestamp(),
//     });

//     var ref =
//         FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

//     var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
//       await _firestore
//           .collection('chatroom')
//           .doc(chatRoomId)
//           .collection('chats')
//           .doc(fileName)
//           .delete();

//       status = 0;
//     });

//     if (status == 1) {
//       String imageUrl = await uploadTask.ref.getDownloadURL();

//       await _firestore
//           .collection('chatroom')
//           .doc(chatRoomId)
//           .collection('chats')
//           .doc(fileName)
//           .update({"message": imageUrl});

//       print(imageUrl);
//     }
//   }

//   void onSendMessage() async {
//     if (_message.text.isNotEmpty) {
//       Map<String, dynamic> messages = {
//         "users": [
//           _auth.currentUser!.uid,
//           userMap['uid'],
//         ],
//         "user_a": _auth.currentUser!.uid,

//         "user_b": userMap['uid'],
//         _auth.currentUser!.uid: {
//           "lastMessage": _message.text,
//           "lastMessageTime": FieldValue.serverTimestamp(),
//           "lastMessageSentBy": _auth.currentUser!.uid,
//           // "lastMessageSeenBy": [_auth.currentUser!.uid],
//         },

//         // userMap['uid']: {
//         //   "lastMessage": _message.text,
//         //   "lastMessageTime": FieldValue.serverTimestamp(),
//         //   "lastMessageSentBy": _auth.currentUser!.uid,
//         //   "lastMessageSeenBy": [_auth.currentUser!.uid],
//         // },
//         // "email": userMap['email'],
//         // "photoUrl": userMap['profilePictureURL'],
//         "isMessageUnread": true,
//       };

//       await _firestore.collection('chats').add(messages);
//       _message.clear();
//     } else {
//       print("Enter Some Text");
//     }
//   }

//   void updateUserLastSeen() {
//     // Update the user's "last seen" timestamp in Firestore
//     _firestore
//         .collection('users')
//         .doc(_auth.currentUser!.uid)
//         .update({"lastSeen": FieldValue.serverTimestamp()});
//   }

//   Widget messages(Size size, Map<String, dynamic> map, BuildContext context) {
//     return map['type'] == "text"
//         ? Container(
//             width: size.width,
//             alignment: map['sendby'] == _auth.currentUser!.displayName
//                 ? Alignment.centerRight
//                 : Alignment.centerLeft,
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//               margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(15),
//                 color: Colors.blue,
//               ),
//               child: Text(
//                 map['lastMessage'],
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           )
//         : Container(
//             height: size.height / 2.5,
//             width: size.width,
//             padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
//             alignment: map['sendby'] == _auth.currentUser!.displayName
//                 ? Alignment.centerRight
//                 : Alignment.centerLeft,
//             child: InkWell(
//               onTap: () => Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (_) => ShowImage(
//                     imageUrl: map['message'],
//                   ),
//                 ),
//               ),
//               child: Container(
//                 height: size.height / 2.5,
//                 width: size.width / 2,
//                 decoration: BoxDecoration(border: Border.all()),
//                 alignment: map['message'] != "" ? null : Alignment.center,
//                 child: map['message'] != ""
//                     ? Image.network(
//                         map['message'],
//                         fit: BoxFit.cover,
//                       )
//                     : const CircularProgressIndicator(),
//               ),
//             ),
//           );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Size size = MediaQuery.of(context).size;

//     return Scaffold(
//       appBar: AppBar(
//         title: ListTile(
//           contentPadding: const EdgeInsets.all(0),
//           leading: const CircleAvatar(
//             child: Icon(Icons.person),
//           ),
//           title: Text(userMap['name']),
//           subtitle: Text(userMap['status']),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _firestore
//                   .collection('chatroom')
//                   .doc(chatRoomId)
//                   .collection('chats')
//                   .orderBy("time", descending: true)
//                   .snapshots(),
//               builder: (BuildContext context,
//                   AsyncSnapshot<QuerySnapshot> snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   return const Center(child: Text('Error loading messages.'));
//                 }
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return const Center(child: Text('No messages yet.'));
//                 }

//                 return ListView.builder(
//                   itemCount: snapshot.data!.docs.length,
//                   reverse: true,
//                   itemBuilder: (context, index) {
//                     Map<String, dynamic> message = snapshot.data!.docs[index]
//                         .data() as Map<String, dynamic>;
//                     return message["lastMessage"];
//                   },
//                 );
//               },
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(8),
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
//                   icon: const Icon(Icons.attach_file),
//                   onPressed: () {
//                     getImage();
//                   },
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
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

// class ShowImage extends StatelessWidget {
//   final String imageUrl;

//   ShowImage({super.key, required this.imageUrl});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Center(
//         child: GestureDetector(
//           onTap: () {
//             Navigator.pop(context);
//           },
//           child: InteractiveViewer(
//             child: Image.network(imageUrl),
//           ),
//         ),
//       ),
//     );
//   }
// }
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:uuid/uuid.dart';

// class ChatRoom extends StatelessWidget {
//   final Map<String, dynamic> userMap;
//   final String chatRoomId;

//   ChatRoom({super.key, required this.chatRoomId, required this.userMap});

//   final TextEditingController _message = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   File? imageFile;

//   String? lastMessageSender;
//   Timestamp? lastMessageDate;

//   bool isMessageRead(Map<String, dynamic> message) {
//     return message['read'] ?? false;
//   }

//   Future getImage() async {
//     ImagePicker _picker = ImagePicker();

//     await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
//       if (xFile != null) {
//         imageFile = File(xFile.path);
//         uploadImage();
//       }
//     });
//   }

//   Future uploadImage() async {
//     String fileName = const Uuid().v1();
//     int status = 1;

//     await _firestore
//         .collection('chatroom')
//         .doc(chatRoomId)
//         .collection('chats')
//         .doc(fileName)
//         .set({
//       "sendby": _auth.currentUser!.displayName,
//       "message": "",
//       "type": "img",
//       "time": FieldValue.serverTimestamp(),
//     });

//     var ref =
//         FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

//     var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
//       await _firestore
//           .collection('chatroom')
//           .doc(chatRoomId)
//           .collection('chats')
//           .doc(fileName)
//           .delete();

//       status = 0;
//     });

//     if (status == 1) {
//       String imageUrl = await uploadTask.ref.getDownloadURL();

//       await _firestore
//           .collection('chatroom')
//           .doc(chatRoomId)
//           .collection('chats')
//           .doc(fileName)
//           .update({"message": imageUrl});

//       print(imageUrl);
//     }
//   }

//   // void onSendMessage() async {
//   //   if (_message.text.isNotEmpty) {
//   //     Map<String, dynamic> messages = {
//   //       "sendby": _auth.currentUser!.displayName,
//   //       "message": _message.text,
//   //       "type": "text",
//   //       "time": FieldValue.serverTimestamp(),
//   //       "read": false,
//   //     };

//   //     _message.clear();
//   //     await _firestore
//   //         .collection('chatroom')
//   //         .doc(chatRoomId)
//   //         .collection('chats')
//   //         .add(messages);
//   //   } else {
//   //     print("Enter Some Text");
//   //   }
//   // }
//   void onSendMessage() async {
//     if (_message.text.isNotEmpty) {
//       Map<String, dynamic> messages = {
//         "users": [
//           _auth.currentUser!.uid,
//           userMap['uid'],
//         ],
//         "user_a": _auth.currentUser!.uid,

//         "user_b": userMap['uid'],
//         "lastMessageTime": FieldValue.serverTimestamp(),

//         "lastMessage": _message.text,
//         // _auth.currentUser!.uid: {
//         //   "lastMessage": _message.text,
//         //   "lastMessageTime": FieldValue.serverTimestamp(),
//         //   "lastMessageSentBy": _auth.currentUser!.uid,
//         //   // "lastMessageSeenBy": [_auth.currentUser!.uid],
//         //  },

//         // userMap['uid']: {
//         //   "lastMessage": _message.text,
//         //   "lastMessageTime": FieldValue.serverTimestamp(),
//         //   "lastMessageSentBy": _auth.currentUser!.uid,
//         //   "lastMessageSeenBy": [_auth.currentUser!.uid],
//         // },
//         // "email": userMap['email'],
//         // "photoUrl": userMap['profilePictureURL'],
//         "isMessageUnread": true,
//       };

//       await _firestore.collection('chats').add(messages);
//       _message.clear();
//     } else {
//       print("Enter Some Text");
//     }
//   }

//   void updateUserLastSeen() {
//     // Update the user's "last seen" timestamp in Firestore
//     _firestore
//         .collection('users')
//         .doc(_auth.currentUser!.uid)
//         .update({"lastSeen": FieldValue.serverTimestamp()});
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Size size = MediaQuery.of(context).size;

//     return Scaffold(
//       appBar: AppBar(
//         title: ListTile(
//           contentPadding: const EdgeInsets.all(0),
//           leading: const CircleAvatar(
//             child: Icon(Icons.person),
//           ),
//           title: Text(userMap['name'] ?? ""),
//           subtitle: Text(userMap['status'] ?? ""),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () {
//               Navigator.pop(context);
//               updateUserLastSeen();
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _firestore
//                   .collection('chats')
//                   .doc(chatRoomId)
//                   .collection('messages')
//                   .orderBy("timestamp")
//                   .snapshots(),
//               builder: (BuildContext context,
//                   AsyncSnapshot<QuerySnapshot> snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(child: Text('Error loading messages.'));
//                 } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return Center(child: Text('No messages yet.'));
//                 }

//                 return ListView.builder(
//                   itemCount: snapshot.data!.docs.length,
//                   itemBuilder: (context, index) {
//                     Map<String, dynamic> messageData =
//                         snapshot.data!.docs[index].data()
//                             as Map<String, dynamic>;
//                     return messages(messageData);
//                   },
//                 );
//               },
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(8),
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
//                   icon: const Icon(Icons.attach_file),
//                   onPressed: () {
//                     getImage();
//                   },
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: () {
//                     onSendMessage();
//                     updateUserLastSeen();
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget messages(Map<String, dynamic> map) {
//     return Container(
//       alignment: map['sendby'] == _auth.currentUser!.displayName
//           ? Alignment.centerRight
//           : Alignment.centerLeft,
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//         margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(15),
//           color: Colors.blue,
//         ),
//         child: Text(
//           map['message'],
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ShowImage extends StatelessWidget {
//   final String imageUrl;

//   ShowImage({super.key, required this.imageUrl});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Center(
//         child: GestureDetector(
//           onTap: () {
//             Navigator.pop(context);
//           },
//           child: InteractiveViewer(
//             child: Image.network(imageUrl),
//           ),
//         ),
//       ),
//     );
//   }
// }
