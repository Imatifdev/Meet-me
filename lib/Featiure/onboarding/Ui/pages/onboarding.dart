import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../config/theme/colors.dart';
import '../../../Authentication/login/ui/pages/login.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  final List<Widget> _onboardingScreens = [
    OnboardingPage(
      subtitle: " SehatGhar World!",
      title: "Welcome to the",
      description:
          "Take a quick tour to see what you can do with SehatGhar App",
      imagePath: 'assets/images/1.png',
    ),
    OnboardingPage(
      title: "Find Trusted Doctors",
      subtitle: "",
      description:
          "Find doctors and book appointment anywhere anytime according to your need.",
      imagePath: 'assets/images/2.png',
    ),
    OnboardingPage(
      subtitle: "",
      title: "Lab Tests",
      description:
          "Book Lab tests from Top Labs by Home Sampling or in-lab sample collection service with a single touch.",
      imagePath: 'assets/images/3.png',
    ),
  ];

  int _currentPage = 0;

  void _goToNextPage() {
    if (_currentPage < _onboardingScreens.length - 1) {
      setState(() {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void skip() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (ctx) => Login()));
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    final subheading = width * 0.04 * textScaleFactor;
    final heading = width * 0.07 * textScaleFactor;

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingScreens.length,
            itemBuilder: (context, index) => _onboardingScreens[index],
          ),
          Positioned(
            left: 16.0,
            right: 16.0,
            bottom: 80.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //if (_currentPage > 0)

                GestureDetector(
                  onTap: _currentPage == 3 ? skip : _goToNextPage,
                  child: Container(
                    width: width - 80,
                    height: height * 0.06,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.green,
                    ),
                    child: Center(
                      child: Text(
                        _currentPage == 0 ? "Getting Started" : "Next",
                        style: TextStyle(
                            color: Colors.white, fontSize: subheading),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
              left: 16.0,
              right: 16.0,
              bottom: 30.0,
              child: MaterialButton(
                onPressed: () {
                  skip();
                },
                child: Text(
                  "Skip",
                  style: TextStyle(fontSize: subheading),
                ),
              )),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  int _currentpage = 0;
  final String title;
  final String description;
  final String imagePath;
  final String subtitle;

  OnboardingPage({
    required this.subtitle,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    final subheading = width * 0.04 * textScaleFactor;
    final heading = width * 0.07 * textScaleFactor;

    return Container(
      padding: EdgeInsets.all(0),
      child: Stack(
        children: [
          Positioned(
            bottom: -100,
            right: -100,
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  width: width / 1.5,
                  height: height / 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.blue.withOpacity(0.7),
                        AppColors.blue.withOpacity(0.3),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -90,
            right: 150,
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 5.0),
                child: Container(
                  width: width / 1,
                  height: height / 2,
                  color: AppColors.green, // Use transparent color
                ),
              ),
            ),
          ),
          // Positioned(
          //   top: 40,
          //   left: 10,
          //   right: 10,
          //   child: Center(
          //     child: Image.asset(
          //       imagePath,
          //       fit: BoxFit.contain,
          //       width: width - 30,
          //       height: height * 0.5,
          //     ),
          //   ),
          // ),
          // Positioned(
          //   bottom: _currentpage == 0 ? 280 : 250,
          //   left: 10,
          //   right: 10,
          //   child: Center(
          //     child: Text(title,
          //         style: TextStyle(
          //             fontSize: heading, fontWeight: FontWeight.bold)),
          //   ),
          // ),
          // Positioned(
          //   bottom: 250,
          //   left: 10,
          //   right: 10,
          //   child: Center(
          //     child: Text(subtitle,
          //         style: TextStyle(
          //             color: AppColors.blue,
          //             fontSize: heading,
          //             fontWeight: FontWeight.bold)),
          //   ),
          // ),
          // Positioned(
          //   bottom: 200,
          //   left: 10,
          //   right: 10,
          //   child: Center(
          //     child: Text(description,
          //         textAlign: TextAlign.center,
          //         style: TextStyle(
          //           fontSize: subheading,
          //         ),),
          //   ),
          // ),
          Column(
            children: [
              SizedBox(
                height: height * 0.05,
              ),
              Image.asset(
                imagePath,
                fit: BoxFit.contain,
                width: width - 30,
                height: height * 0.5,
              ),
              SizedBox(
                height: height * 0.05,
              ),
              Text(title,
                  style: TextStyle(
                      fontSize: heading, fontWeight: FontWeight.bold)),
              Text(subtitle,
                  style: TextStyle(
                      color: AppColors.blue,
                      fontSize: heading,
                      fontWeight: FontWeight.bold)),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: subheading,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
