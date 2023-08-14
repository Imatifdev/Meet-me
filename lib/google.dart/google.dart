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
          try {
            final googleSignIn = GoogleSignIn();
            final googleUser = await googleSignIn.signIn();
            final googleAuth = await googleUser!.authentication;

            final credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );

            final userCredential =
                await FirebaseAuth.instance.signInWithCredential(credential);

            final user = userCredential.user;
            final displayName = user!.displayName;
            final email = user.email;
            final phone = user.phoneNumber;
            //ssave data in firestore
            FirebaseFirestore.instance.collection('users').doc(user.uid).set({
              'First Name': displayName,
              'Email': email,
              'Phone': phone
              // Add more fields as needed
            });
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (ctx) => HomePage()));
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
        child: Center(
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
