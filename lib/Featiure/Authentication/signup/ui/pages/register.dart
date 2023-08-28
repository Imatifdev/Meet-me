import 'dart:io';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meetly/Featiure/Authentication/login/login_bloc/login_bloc.dart';
import 'package:meetly/Featiure/Authentication/login/login_bloc/login_event.dart';
import 'package:meetly/Featiure/Authentication/login/login_bloc/login_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meetly/chat_home.dart';
import '../../../../home/ui/pages/homepage.dart';
import '../../../login/ui/pages/login.dart';
import 'package:image_picker/image_picker.dart'; // Add this import

class Register extends StatefulWidget {
  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  File? _profilePicture; // Add this property
  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profilePicture = File(pickedFile.path);
      });
      print(_profilePicture!.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height;
    final width = mediaQuery.size.width;
    final textScaleFactor = mediaQuery.textScaleFactor;
    final fontSize = width * 0.04 * textScaleFactor;
    final subheading = width * 0.04 * textScaleFactor;
    final heading = width * 0.07 * textScaleFactor;

    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is AuthErrorState) {
            return Center(
              child: Text(state.error),
            );
          } else if (state is AuthLoggedInState) {
            // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => ChatHome()), (route) => false);
            return Center(
              child: TextButton(
                child: const Text("You logged In. Click here to move forward"),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ));
                },
              ),
            );
          } else {
            return SafeArea(
              child: Form(
                key: _formKey,
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
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: height * 0.09,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Join ",
                                  style: TextStyle(
                                      fontSize: heading,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Meetly",
                                  style: TextStyle(
                                      fontSize: heading,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.lightBlue.shade900),
                                ),
                              ],
                            ),
                            SizedBox(height: height * 0.020),
                            SizedBox(
                              width: width - 80,
                              child: Text(
                                "Be part of a community of people who are happy to chat and share",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: fontSize),
                              ),
                            ),
                            SizedBox(height: height * 0.020),
                            ElevatedButton(
                              onPressed: _pickImage,
                              child: Text("Pick Profile Picture"),
                            ),

                            buildTextFormField('Full Name*', _nameController),
                            SizedBox(height: height * 0.02),
                            buildTextFormField(
                              'Email*',
                              _emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: height * 0.02),
                            buildTextFormField('Age', _ageController,
                                keyboardType: TextInputType.number),
                            SizedBox(height: height * 0.02),
                            buildTextFormField(
                              'Password*',
                              _passwordController,
                              obscureText: _obscurePassword,
                              keyboardType: TextInputType.visiblePassword,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.02),
                            buildTextFormField(
                              'Confirm Password*',
                              _confirmpasswordController,
                              obscureText: _obscureConfirmPassword,
                              keyboardType: TextInputType.visiblePassword,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),

                            // SizedBox(height: height * 0.02),
                            // buildCheckboxAndDropdown(),
                            SizedBox(height: height * 0.02),
                            buildSignUpButton(
                                subheading,
                                _emailController.text,
                                _passwordController.text,
                                _nameController.text,
                                _ageController.text),
                            const SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                                width: width - 90,
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Image.asset(
                                          "assets/images/google-G.png",
                                          height: 40,
                                          width: 40,
                                        ),
                                        Image.asset(
                                          "assets/images/fb-F.png",
                                          height: 40,
                                          width: 40,
                                        ),
                                        Image.asset(
                                          "assets/images/apple.png",
                                          height: 40,
                                          width: 40,
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                            buildTermsAndConditions(),
                            SizedBox(height: height * 0.07),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  TextFormField buildTextFormField(
      String labelText, TextEditingController controller,
      {bool obscureText = false,
      TextInputType? keyboardType,
      Widget? suffixIcon}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        hintText: labelText,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: suffixIcon,
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelText';
        } else if (labelText == "Confirm Password*" &&
            value != _passwordController.text) {
          return "Your password does not match";
        }
        return null;
      },
    );
  }

  Container buildSignUpButton(double subheading, String email, String password,
      String fullName, String age) {
    return Container(
      height: subheading * 3,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            BlocProvider.of<AuthBloc>(context).add(SignUpEvent(
                email, password, fullName, age.toString(), _profilePicture!));
          }
        },
        child: Text(
          "Sign up",
          style: TextStyle(color: Colors.white, fontSize: subheading),
        ),
      ),
    );
  }

  Widget buildTermsAndConditions() {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: 'By Becoming a member, you agree',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            children: <TextSpan>[
              const TextSpan(
                text: 'to our ',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              TextSpan(
                text: 'Terms & Conditions',
                style: TextStyle(
                  color: Colors.lightBlue.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: 'Already have an account?',
                style: TextStyle(
                  color: Colors.lightBlue.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
              TextSpan(
                text: ' Login',
                style: TextStyle(
                  color: Colors.lightBlue.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (ctx) => Login()));
                  },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
