// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meetly/Featiure/Authentication/login/login_bloc/login_bloc.dart';
import 'package:meetly/Featiure/splash/ui/splash.dart';
import 'package:meetly/chat_home.dart';
import 'package:meetly/firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  OneSignal.initialize("6d457447-697b-460f-8ebf-e44c8748d188"); 
  OneSignal.Notifications.requestPermission(false).then((accepted) {print("One Signal Permision $accepted");});
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  MobileAds.instance.initialize();

  RequestConfiguration requestConfiguration =
      RequestConfiguration(testDeviceIds: ["DD7BB1557CF7EA7AA9900A3BCA535D66"]);
  MobileAds.instance.updateRequestConfiguration(requestConfiguration);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<AuthBloc>(create: (context) => AuthBloc())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Meetly',
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
            useMaterial3: true,
            fontFamily: GoogleFonts.poppins().fontFamily),
        home: ChatHome(),
      ),
    );
  }
}
