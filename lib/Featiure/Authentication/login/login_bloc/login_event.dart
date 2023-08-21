import 'dart:io';

abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent(this.email, this.password);
}

class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String age;
  final File profilePicture; // Add this property for the profile picture

  SignUpEvent(
      this.email, this.password, this.fullName, this.age, this.profilePicture);
}

class LogoutEvent extends AuthEvent {}
