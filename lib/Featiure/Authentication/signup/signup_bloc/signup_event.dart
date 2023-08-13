import 'package:meetly/Featiure/Authentication/login/login_bloc/login_event.dart';

class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String phoneNumber;
  final int age;

  SignUpEvent(this.email, this.password, this.fullName, this.phoneNumber, this.age);
}