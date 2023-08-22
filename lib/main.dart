import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meetly/Featiure/Authentication/login/login_bloc/login_bloc.dart';
import 'package:meetly/Featiure/admin/ui/admin_dashboard.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:meetly/firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  MobileAds.instance.initialize();
  FacebookAudienceNetwork.init(
    testingId: "c4b5f429-5e2f-487b-8fe1-430d4f209b99"
  );
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
        home: AdminDashboard(),
      ),
    );
  }
}
