import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meetly/Featiure/Authentication/login/login_bloc/login_event.dart';
import 'package:meetly/Featiure/Authentication/login/login_bloc/login_states.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc() : super(AuthInitialState()) {
    on<LoginEvent>((event, emit) async {
      try {
        UserCredential authResult = await _auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        emit(AuthLoggedInState(authResult.user!));
      } catch (e) {
        emit(AuthErrorState(e.toString()));
      }
    });

    on<SignUpEvent>((event, emit) async {
      try {
        // Register the user with email and password
        UserCredential authResult = await _auth
            .createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        )
            .then((value) {
          value.user?.updateDisplayName(event.fullName);
          return value;
        });

        // Upload profile picture
        String profilePictureUrl = '';
        if (event.profilePicture != null) {
          // Upload the profile picture to a storage location (e.g., Firebase Storage)
          profilePictureUrl = await _uploadProfilePicture(
              event.profilePicture, authResult.user!.uid);
        }

        // Store user data in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user!.uid)
            .set({
          "name": event.fullName,
          "email": event.email,
          "status": "Unavailable",
          "uid": authResult.user!.uid,
          "profilePictureUrl":
              profilePictureUrl, // Store the profile picture URL
        });

        emit(AuthLoggedInState(authResult.user!));
      } catch (e) {
        emit(AuthErrorState(e.toString()));
      }
    });
  }
}

Future<String> _uploadProfilePicture(File profilePicture, String userId) async {
  try {
    final storageReference = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('profilePictures/$userId.jpg');
    final uploadTask = storageReference.putFile(profilePicture);
    await uploadTask.whenComplete(() {});
    final downloadUrl = await storageReference.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    print("Error uploading profile picture: $e");
    return ''; // Return an empty string or handle the error accordingly
  }
}
