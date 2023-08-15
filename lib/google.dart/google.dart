// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meetly/Featiure/home/ui/pages/homepage.dart';

class GoogleAuthWidget extends StatelessWidget {
  const GoogleAuthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () async {
          print("test 1");
          try {
            print("test 2");
            final googleSignIn = GoogleSignIn();
            print("test 3");
            final googleUser = await googleSignIn.signIn();
            print("test 4");
            final googleAuth = await googleUser!.authentication;
            print("test 5");
            final credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );
            print("test 6");

            final userCredential =
                await FirebaseAuth.instance.signInWithCredential(credential);
                print("test 7");
            final user = userCredential.user;
            final displayName = user!.displayName;
            final email = user.email;
            final phone = user.phoneNumber;
            //ssave data in firestore
            print("test 8");
            FirebaseFirestore.instance.collection('users').doc(user.uid).set({
              'First Name': displayName,
              'Email': email,
              'Phone': phone
              // Add more fields as needed
            });
            print("test 9");
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (ctx) => const HomePage()));
          } catch (e) {
            if (e is FirebaseAuthException) {
              if (e.code == 'account-exists-with-different-credential') {
                print('An account with the same email already exists');
              } else {
                print('Failed to sign up with Google: ${e.message}');
              }
            } else {
              print('Failed to sign up with Google: $e');
            }
          }
        },
        child: const Center(
          child: Image(
              fit: BoxFit.cover,
              height: 60,
              width: 60,
              image: AssetImage('assets/images/logo.png')),
        ),
      ),
    );
  }
}
