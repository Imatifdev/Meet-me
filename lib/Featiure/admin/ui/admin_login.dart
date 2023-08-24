// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meetly/Featiure/admin/ui/admin_dashboard.dart';

class AdminLoginScreen extends StatefulWidget {
  static const routeName = "login";

  const AdminLoginScreen({super.key});
  @override
  AdminLoginScreenState createState() => AdminLoginScreenState();
}

class AdminLoginScreenState extends State<AdminLoginScreen> {
  bool obsCheck = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoggingIn = false;
  final LoginViewModel _loginVM = LoginViewModel();
  String errMsg = "";

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                    Column(
                      children: [
                        Image.asset(
                         "assets/images/logo.png",
                          width: size.width/1.6,
                          height: size.height/5,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
              const Text("Sign in", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
              const SizedBox(height: 10,),
              const Text("Welcome Back Admin", style: TextStyle(color: Colors.grey),),
              const SizedBox(height: 44,),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Container(
                          decoration: const BoxDecoration(
                              border: Border(
                                right:   BorderSide(width: 1.0, color: Colors.black),
                              ),
                          ),
                          child: const Icon(Icons.email_outlined)),
                      ),
                      labelText: 'Email Address',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30,),
                  TextFormField(
                    controller: _passwordController,
                    decoration:  InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Container(
                          decoration: const BoxDecoration(
                                border: Border(
                                  right:   BorderSide(width: 1.0, color: Colors.black),
                                ),
                            ),
                          child: const Icon(Icons.lock_open_rounded)),
                      ),
                      labelText: 'Password',
                      suffixIcon: IconButton(onPressed: (){
                        setState(() {
                          obsCheck =!obsCheck;
                        });
                      }, icon: Icon( obsCheck? Icons.visibility : Icons.visibility_off))
                    ),
                    obscureText: !obsCheck,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  Text(errMsg, style: const TextStyle(color: Colors.red)),
                  // Align(
                  //   alignment: Alignment.bottomRight,
                  //   child: TextButton(child: Text("Forgot Password?"),onPressed: (){
                  //     Navigator.of(context).pushNamed(ForgotPassword.routeName);
                  //   }, )),
                  // const SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: ElevatedButton(
                      onPressed: _isLoggingIn ? null : () async{
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoggingIn = true;
                          });
                           bool isLoggedIn = await _loginVM.login(_emailController.text, _passwordController.text);
                           if(isLoggedIn){
                             Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (ctx) => const AdminDashboard()),(Route<dynamic> route) => false);
                           }else{
                           setState(() {
                          _isLoggingIn = false;  
                          errMsg = _loginVM.message;
                          });
                         }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.fromLTRB(size.width/4, size.height/40, size.width/4, size.height/40),
                        shape: RoundedRectangleBorder( //to set border radius to button
                  borderRadius: BorderRadius.circular(50)
                            ),),
                      child: _isLoggingIn
                        ? const CircularProgressIndicator()
                        : const Text('Sign In'),  
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // TextButton(
                  //   onPressed: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(builder: (context) => SignupScreen()),
                  //     );
                  //   },
                  //   child: const Text('Don\'t have an account? Sign up here'),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



class LoginViewModel extends ChangeNotifier {
  String message = "";

  Future<bool> login(String email, String password) async {
    bool isLoggedIn = false;

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      isLoggedIn = userCredential != null;
    } on FirebaseAuthException catch (e) {
      message = e.code;
      notifyListeners();
    } catch (e) {
      print(e);
    }

    return isLoggedIn;
  }
}