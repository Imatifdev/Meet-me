import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meetly/Featiure/admin/models/fake_user.dart';

class AddFakeUserScreen extends StatefulWidget {
  const AddFakeUserScreen({super.key});

  @override
  AddFakeUserScreenState createState() => AddFakeUserScreenState();
}

class AddFakeUserScreenState extends State<AddFakeUserScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController age = TextEditingController();
  bool status = false;
  bool isImageUploaded = false;
  String imgUrl = '';

  final ImagePicker _imagePicker = ImagePicker();
  File? _pickedFile;
  String name = "";
  bool isLoading = false;

  Future<void> _getImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = File(pickedFile.path);
        name = _pickedFile!.path;
      });
    }
  }

  Future<void> _uploadImage() async {
    setState(() {
      isLoading = true;
    });
    if(!isImageUploaded){
      final Reference ref =
        FirebaseStorage.instance.ref().child('fakeUsers/${DateTime.now()}.png');
    final UploadTask uploadTask = ref.putFile(File(_pickedFile!.path));

    await uploadTask.whenComplete(() {
      ref.getDownloadURL().then((value) {
        setState(() {
          imgUrl = value;
        });
        print("image Url: $imgUrl");
      });
    }).then((value){
      if(value.state == TaskState.success){
        setState(() {
          isImageUploaded = true;
        });
      }
    }) ;
    }
  }

  Future<void> addUserToFirestore(FakeUser user) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    try {
      await _firestore.collection('fakeUsers').add({
        'firstName': user.firstName,
        'lastName': user.lastName,
        'age': user.age,
        'status': user.status,
        'imgUrl': user.imgUrl,
      }).then((value){
        setState(() {
      isLoading = false;
    });
    Fluttertoast.showToast(
      backgroundColor: Colors.green,
      msg: "Fake User Added",
      gravity: ToastGravity.BOTTOM,
      textColor: Colors.white,
      fontSize: 20,
      toastLength: Toast.LENGTH_SHORT
      );
    Navigator.of(context).pop();
      });
      print('User added to Firestore successfully');
    } catch (e) {
      setState(() {
      isLoading = false;
    });
      print('Error adding user to Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add User'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: firstName,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter value";
                  }
                  return null; 
                },
              ),
              TextFormField(
                controller: lastName,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter value";
                  }
                  return null; 
                },
              ),
              TextFormField(
                controller: age,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter value";
                  }
                  return null; 
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text("Status", style: TextStyle(fontSize: 16),),
                  Column(
                    children: [
                      Switch(
                        activeColor: Colors.blue,
                          value: status,
                          onChanged: (value) {
                            setState(() {
                              status = !status;
                            });
                          }),
                          Text(status?"Online":"Offline")
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      _getImage();
                    },
                    child: const Text('Pick Image'),
                  ),
                  Expanded(child: Text(name))
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20)
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _uploadImage();
                    FakeUser user = FakeUser(
                      id: DateTime.now().toString(),firstName: firstName.text,lastName: lastName.text,age: int.parse(age.text),status: status,imgUrl: imgUrl);
                    addUserToFirestore(user);
                  }
                },
                child: isLoading? const CircularProgressIndicator() :const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
