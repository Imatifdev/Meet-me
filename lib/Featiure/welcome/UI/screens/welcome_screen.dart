import 'package:flutter/material.dart';
import 'package:meetly/Featiure/Authentication/login/ui/pages/login.dart';
import 'package:meetly/Featiure/Authentication/signup/ui/pages/register.dart';
import 'package:meetly/Featiure/admin/ui/admin_login.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade100,
      body: SafeArea(child: 
      SizedBox(
        width: size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: size.width/2,
              width: size.width/2,
              child: Image.asset("assets/images/logo.png"),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Meetly", style: TextStyle(fontSize: 22),),
            ),
            const SizedBox(height: 40,),
            Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 25),
                  ),
                  onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => Register(),));
                  }, child: const Text("Signup")),
                const SizedBox(height: 10,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 25),
                  ),
                  onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Login(),));
                  }, child: const Text("Signin")),
                  TextButton(onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => AdminLoginScreen(),));
                  }, child: const Text("Admin Panel"))
              ],
            ),
            
          ],
        ),
      ) ),
    );
  }
}