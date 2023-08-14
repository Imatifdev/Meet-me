import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meetly/Featiure/Authentication/login/login_bloc/login_event.dart';
import 'package:meetly/Featiure/Authentication/login/login_bloc/login_states.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
        UserCredential authResult = await _auth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        ).then((value) {
          value.user?.updateDisplayName(event.fullName);
          return value;
        });
        await FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid).set({
      "name": event.fullName,
      "email": event.email,
      "status": "Unavalible",
      "uid": _auth.currentUser!.uid,
    });
        emit(AuthLoggedInState(authResult.user!));
      } catch (e) {
        emit(AuthErrorState(e.toString()));
      }
    });
  }
}
