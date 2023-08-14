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
        );
        emit(AuthLoggedInState(authResult.user!));
      } catch (e) {
        emit(AuthErrorState(e.toString()));
      }
    });
  }
}
