import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'chat_room.dart';

class ChatHome extends StatefulWidget {
  @override
  _ChatHomeState createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: isLoading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        height: size.height / 20,
                        width: size.height / 20,
                        child: const CircularProgressIndicator(),
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SizedBox(height: size.height / 10),
                    // InkWell(
                    //   onTap: () => Navigator.pop(context),
                    //   child: const Icon(
                    //     CupertinoIcons.left_chevron,
                    //     size: 40,
                    //   ),
                    // ),
                    SizedBox(height: size.height / 20),
                    Container(
                      height: size.height / 14,
                      width: size.width,
                      alignment: Alignment.center,
                      child: Container(
                        height: size.height / 14,
                        width: size.width / 1.15,
                        child: TextFormField(
                          textInputAction: TextInputAction.done,
                          controller: _search,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: onSearch,
                              icon: const Icon(Icons.search),
                            ),
                            hintText: "Search...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                   // SizedBox(height: size.height / 50),
                    //SizedBox(height: size.height / 30),
                    // userMap != null
                    //     ? ListTile(
                    //         onTap: () {
                    //           String roomId = chatRoomId(
                    //             _auth.currentUser!.displayName!,
                    //             userMap!['name'],
                    //           );

                    //           Navigator.of(context).push(
                    //             MaterialPageRoute(
                    //               builder: (_) => ChatRoom(
                    //                 chatRoomId: roomId,
                    //                 userMap: userMap!,
                    //               ),
                    //             ),
                    //           );
                    //         },
                    //         leading: Container(
                    //           height: 50,
                    //           width: 50,
                    //           decoration: BoxDecoration(
                    //             color: Colors.grey.shade200,
                    //             borderRadius: BorderRadius.circular(100),
                    //             border: Border.all(width: 1),
                    //           ),
                    //           child: userMap!['profilePictureUrl'] != null
                    //               ? CircleAvatar(
                    //                   backgroundImage: NetworkImage(
                    //                     userMap!['profilePictureUrl'],
                    //                   ),
                    //                 )
                    //               : const Icon(
                    //                   CupertinoIcons.person_2,
                    //                   color: Colors.black,
                    //                 ),
                    //         ),
                    //         title: Text(
                    //           userMap!['name'],
                    //           style: const TextStyle(
                    //             color: Colors.black,
                    //             fontSize: 17,
                    //             fontWeight: FontWeight.w500,
                    //           ),
                    //         ),
                    //         subtitle: Text(userMap!['email']),
                    //         trailing: const Icon(
                    //           Icons.mobile_friendly,
                    //           color: Colors.black,
                    //         ),
                    //       )
                    //     : Center(
                    //         child: Text("User not found"),
                    //       ),
                    allUsers.isNotEmpty?
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: allUsers.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> userData = allUsers[index];
                        return ListTile(
                          onTap: () {
                            String roomId = chatRoomId(
                              _auth.currentUser!.displayName!,
                              userData['name'],
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
                            child: userData.containsKey('profilePictureURL')
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      userData['profilePictureURL'],
                                    ),
                                  )
                                : const Icon(
                                    CupertinoIcons.person_2,
                                    color: Colors.black,
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
                            Icons.mobile_friendly,
                            color: Colors.black,
                          ),
                        );
                      },
                    ): Center(child: const CircularProgressIndicator()),
                  ],
                ),
        ),
      ),
    );
  }
}
