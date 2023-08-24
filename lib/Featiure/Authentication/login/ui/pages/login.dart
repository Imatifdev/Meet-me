// ignore_for_file: depend_on_referenced_packages

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meetly/Featiure/Authentication/login/login_bloc/login_event.dart';
import 'package:meetly/Featiure/Authentication/login/login_bloc/login_states.dart';
import 'package:meetly/chat_home.dart';
import './../../login_bloc/login_bloc.dart';

import '../../../../../config/theme/colors.dart';

import '../../../signup/ui/pages/register.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  void _showForgotPasswordBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return ForgotPasswordSheet(_emailController);
      },
    );
  }

  void _showOtpScreen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return OtpSheet(_buildOtpBox, _showresetpass);
      },
    );
  }

  void _showresetpass() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return ResetPasswordSheet(_emailController, _showOtpScreen);
      },
    );
  }

  Widget _buildOtpBox() {
    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.green),
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextFormField(
        maxLength: 1,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 20),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final fontsizeSmall = width * 0.04 * textScaleFactor;
    final fontsize2 = width * 0.04 * textScaleFactor;
    final subheading = width * 0.04 * textScaleFactor;
    final heading = width * 0.07 * textScaleFactor;

    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
         builder: (context, state){
           if (state is AuthLoadingState) {
            return const CircularProgressIndicator();
          } else if (state is AuthErrorState) {
            return Center(child: Text(state.error));
          } else if (state is AuthLoggedInState) {
          //  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => ChatHome()), (route) => false);
           return Center(child: TextButton(child: const Text("You logged In, Click here to move forward"), onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatHome(),));
            },),);
          }
            return SafeArea(
          child: SingleChildScrollView(
            child: Stack(
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    width: width,
                    height: height,
                    color: Colors.transparent,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: width / 3,
                              width: width/3,
                            ),
                          ),
                          Text(
                            "Welcome back to Meetly",
                            style: TextStyle(
                                fontSize: heading-6, fontWeight: FontWeight.bold),
                          ),
                          
                        ],
                      ),
                      SizedBox(
                        height: height * 0.020,
                      ),
                      Text(
                        "Securely Login & \nStart exploring new people",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: fontsizeSmall),
                      ),
                      SizedBox(
                        height: height * 0.020,
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                hintText: 'Email*',
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                else if( !value.contains("@")){
                                  return "Please enter valid email";
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                        height: height * 0.02,
                      ),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: 'Password*',
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _showForgotPasswordBottomSheet(context);
                        },
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                                fontSize: fontsize2-3,
                                color: Colors.lightBlue.shade900,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          if(_formKey.currentState!.validate()){
                            setState(() {
                            isLoading = true;
                          });
                           BlocProvider.of<AuthBloc>(context).add(LoginEvent(
                        _emailController.text,
                        _passwordController.text,
                      ));
                      setState(() {
                        isLoading = false;
                      });
                          }
                        },
                        child: Container(
                          height: height * 0.07,
                          width: width - 100,
                          decoration: BoxDecoration(
                              color: Colors.lightBlue.shade900,
                              borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: 
                            isLoading? const CircularProgressIndicator(color: Colors.white) :
                            Text(
                              "Login",
                              style: TextStyle(
                                  color: Colors.white, fontSize: subheading),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      SizedBox(
                        width: width-90,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Image.asset("assets/images/google-G.png", height: 40, width: 40,),
                                const Text("Continue with Google")
                              ],
                            ),
                          ),
                        )),
                      const SizedBox(height: 10,),
                      SizedBox(
                        width: width-90,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Image.asset("assets/images/fb-F.png", height: 40, width: 40,),
                                const Text("Continue with Facebook")
                              ],
                            ),
                          ),
                        )),
                      const SizedBox(height: 10,),
                      SizedBox(
                        width: width-90,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Image.asset("assets/images/apple.png", height: 40, width: 40,),
                                const Text("Continue with Apple")
                              ],
                            ),
                          ),
                        )),
                      RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Don\'t Have an account?',
                              style: TextStyle(
                                color: Colors.lightBlue.shade900,
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                fontWeight: FontWeight.bold,
                                fontSize: fontsize2-2,
                              ),
                            ),
                            TextSpan(
                              text: ' Join us',
                              style: TextStyle(
                                color: Colors.lightBlue.shade900,
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                fontWeight: FontWeight.bold,
                                fontSize: fontsize2-2,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (ctx) => Register()));
                                },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: height * 0.07,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
          }
         
      ),
    );
  }
}

class ForgotPasswordSheet extends StatelessWidget {
  final TextEditingController _emailController;

  ForgotPasswordSheet(this._emailController, {super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final subheading = width * 0.04 * textScaleFactor;

    return SingleChildScrollView(
      child: GestureDetector(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              height: 400,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: height * 0.09,
                    ),
                    const Text(
                      "Forgot Password",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    const Text(
                        "Enter your Phone No for the verification process, we will send a 4-digit code to your email."),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Phone No*',
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.green),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    Center(
                      child: InkWell(
                        onTap: () {},
                        child: Container(
                          height: height * 0.07,
                          width: width - 100,
                          decoration: BoxDecoration(
                              color: AppColors.green,
                              borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Text(
                              "Continue",
                              style: TextStyle(
                                  color: Colors.white, fontSize: subheading),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OtpSheet extends StatelessWidget {
  final Function _buildOtpBox;
  final Function _showresetpass;

  OtpSheet(this._buildOtpBox, this._showresetpass, {super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final subheading = width * 0.04 * textScaleFactor;

    return SingleChildScrollView(
      child: GestureDetector(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              height: height / 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: height * 0.08,
                    ),
                    const Text(
                      "OTP Screen",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text("Enter the 4-digit code sent to your email."),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildOtpBox(),
                        const SizedBox(width: 16),
                        _buildOtpBox(),
                        const SizedBox(width: 16),
                        _buildOtpBox(),
                        const SizedBox(width: 16),
                        _buildOtpBox(),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _showresetpass();
                        },
                        child: Container(
                          height: height * 0.07,
                          width: width - 100,
                          decoration: BoxDecoration(
                              color: AppColors.green,
                              borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Text(
                              "Continue",
                              style: TextStyle(
                                  color: Colors.white, fontSize: subheading),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ResetPasswordSheet extends StatelessWidget {
  final TextEditingController _emailController;
  final Function _showOtpScreen;

  ResetPasswordSheet(this._emailController, this._showOtpScreen, {super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final subheading = width * 0.04 * textScaleFactor;

    return SingleChildScrollView(
      child: GestureDetector(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              height: height / 1.5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: height * 0.08,
                    ),
                    const Text(
                      "Reset Password",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    const Text(
                        "Set the new password for your account so you can login and access all the features."),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'New Password*',
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.green),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your new password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Confirm Password*',
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.green),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    Center(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _showOtpScreen();
                        },
                        child: Container(
                          height: height * 0.07,
                          width: width - 100,
                          decoration: BoxDecoration(
                              color: Colors.lightBlue.shade900,
                              borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Text(
                              "Update Password",
                              style: TextStyle(
                                  color: Colors.white, fontSize: subheading),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
