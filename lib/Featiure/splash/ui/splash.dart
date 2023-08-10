import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../config/theme/colors.dart';
import '../../onboarding/Ui/pages/onboarding.dart';
import '../bloc/splacbloc.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      navigationBloc.navigateToOnboarding();
    });
  }

  @override
  void dispose() {
    navigationBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: StreamBuilder<bool>(
        stream: navigationBloc.navigateStream,
        initialData: false,
        builder: (context, snapshot) {
          if (snapshot.data == true) {
            // Navigate to Onboarding screen
            // You can replace the OnboardingScreen() with your actual onboarding screen widget.
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => OnboardingScreen(),
                ),
              );
            });
          } //
          return Stack(
            children: [
              // Add glass effect to the entire screen
              Center(child: Image(image: AssetImage('assets/images/logo.png'))),
            ],
          );
        },
      ),
    );
  }
}
