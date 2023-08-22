import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

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
  String imgUrl = '';

  final ImagePicker _imagePicker = ImagePicker();
  File? _pickedFile;
  String name = "";

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
    final Reference ref =
        FirebaseStorage.instance.ref().child('images/${DateTime.now()}.png');
    final UploadTask uploadTask = ref.putFile(File(_pickedFile!.path));

    await uploadTask.whenComplete(() {
      ref.getDownloadURL().then((value) {
        setState(() {
          imgUrl = value;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Screen'),
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
                  } else {
                    return "";
                  }
                },
              ),
              TextFormField(
                controller: lastName,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter value";
                  } else {
                    return "";
                  }
                },
              ),
              TextFormField(
                controller: age,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter value";
                  } else {
                    return "";
                  }
                },
              ),
              Switch(
                  value: status,
                  onChanged: (value) {
                    setState(() {
                      status = !status;
                    });
                  }),
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
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    await _uploadImage();
                    // Now, you can use the firstName, lastName, age, status, and imgUrl.
                    // For example, you can send this data to Firebase Firestore.
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
