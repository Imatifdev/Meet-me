import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState {}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthLoggedInState extends AuthState {
  final User user;

  AuthLoggedInState(this.user);
}

class AuthErrorState extends AuthState {
  final String error;

  AuthErrorState(this.error);
}