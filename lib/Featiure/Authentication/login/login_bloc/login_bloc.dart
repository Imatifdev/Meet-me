import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meetly/Featiure/Authentication/login/login_bloc/login_event.dart';
import 'package:meetly/Featiure/Authentication/login/login_bloc/login_states.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc() : super(AuthInitialState()){
    
    on<LoginEvent>((event, emit) async{
        try{
          UserCredential authResult = await _auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        emit(AuthLoggedInState(authResult.user!));
        } catch(e){
          emit(AuthErrorState(e.toString()));
        }
    });

    on<SignUpEvent>((event, emit) async{
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

 


  // // Stream<AuthState> mapEventToState(AuthEvent event) async* {
    
    
  // //   if (event is LoginEvent) {
  // //     on<LoginEvent>((event, emit) {});
  // //     try {
  // //       UserCredential authResult = await _auth.signInWithEmailAndPassword(
  // //         email: event.email,
  // //         password: event.password,
  // //       );
        
  // //       //yield AuthLoggedInState(authResult.user!);
  // //     } catch (e) {
  // //       yield AuthErrorState(e.toString());
  // //     }
  // //   } else if (event is SignUpEvent) {
  // //     yield AuthLoadingState();
  // //     try {
  // //       UserCredential authResult = await _auth.createUserWithEmailAndPassword(
  // //         email: event.email,
  // //         password: event.password,
  // //       );
  // //       yield AuthLoggedInState(authResult.user!);
  // //     } catch (e) {
  // //       yield AuthErrorState(e.toString());
  // //     }
  // //   } else if (event is LogoutEvent) {
  // //     yield AuthLoadingState();
  // //     try {
  // //       await _auth.signOut();
  // //       yield AuthInitialState();
  // //     } catch (e) {
  // //       yield AuthErrorState(e.toString());
  // //     }
  // //   }
  // }
}