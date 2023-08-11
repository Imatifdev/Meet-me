import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meetme/Featiure/splash/ui/splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
        fontFamily: GoogleFonts.poppins().fontFamily
      ),
      home: SplashScreen(),
    );
  }
}