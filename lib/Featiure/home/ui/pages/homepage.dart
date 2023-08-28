import 'dart:io';

import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:meetly/Featiure/admin/ui/add_fake_user_screen.dart';
import 'package:meetly/Featiure/mobile%20ads/ads.dart';
import 'package:meetly/chat_home.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _currentIndex = 0; // To keep track of the selected tab index

  // List of screens to display in each tab
  final List<Widget> _screens = [
    // Add your different screens here
    const Screen1(),
    const ChatHome(),
    const Screen3(),
    const Screen4(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Tab 1',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Tab 2',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Tab 3',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tab 4',
          ),
        ],
        onTap: (index) {
          // Switch to the selected tab when tapped
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class Screen1 extends StatefulWidget {
  const Screen1({super.key});

  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
BannerAd? _bannerAd;

    //fb ad
    Widget _currentAd = const SizedBox(
    width: 0.0,
    height: 0.0,
  );

    @override
  void initState() {
  //   FacebookAudienceNetwork.init(
  //   testingId: "c4b5f429-5e2f-487b-8fe1-430d4f209b99",
  // );
    FacebookAudienceNetwork.init(
        testingId: "aa3ba621-b601-4f89-9a01-d4e36cfe43eb"); 
    _showBannerAd();
    BannerAd(
    adUnitId: AdHelper.bannerAdUnitId,
    request: const AdRequest(),
    size: AdSize.banner,
    listener: BannerAdListener(
      
      onAdLoaded: (ad) {
        setState(() {
          _bannerAd = ad as BannerAd;
        });
      },
      onAdFailedToLoad: (ad, err) {
        print('Failed to load a banner ad: ${err.message}');
        ad.dispose();
      },
    ),
  ).load();
    super.initState();
  }

  //fb
  _showBannerAd() {
    setState(() {
      _currentAd = FacebookBannerAd(
        // placementId: "YOUR_PLACEMENT_ID",
        placementId: "3547050492249770_3547050788916407", //testid
        //size of banner ad
        bannerSize: BannerSize.STANDARD,
        listener: (result, value) {
          print("Banner Ad: $result -->  $value");
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
           if (_bannerAd != null)
              SizedBox(
                //width:MediaQuery.of(context).size.width,
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
              const SizedBox(height: 10,),
              
              FacebookBannerAd(
                placementId: Platform.isAndroid ? "3547050492249770_3547050788916407" : "1698061277334331_1698061574000968",
                bannerSize: BannerSize.STANDARD,
                listener: (result, value) {
                  switch (result) {
                    case BannerAdResult.ERROR:
                      print("Error: $value");
                      break;
                    case BannerAdResult.LOADED:
                      print("Loaded: $value");
                      break;
                    case BannerAdResult.CLICKED:
                      print("Clicked: $value");
                      break;
                    case BannerAdResult.LOGGING_IMPRESSION:
                      print("Logging Impression: $value");
                      break;
                  }
                },
              ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Total Users: 10", style: TextStyle(fontSize: 18, ),),
            ),
            IconButton(onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddFakeUserScreen(),));
            }, icon: const Icon(Icons.add_box_rounded, size: 40,))
          ],),
          Expanded(
           // height:400,
           flex: 6,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 10
                ),
                itemCount: 10,
              itemBuilder: (context, index) => SizedBox(
                height: 100,
                width: 100,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage("https://images.unsplash.com/photo-1580483046931-aaba29b81601?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=387&q=80"))
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                       Row(
                         children: [
                           Text("User's Name", style: TextStyle(
                            color: Colors.white
                           ),),
                         ],
                       ),
                       Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               Row(
                                 children: [
                                   Icon(Icons.circle, color: Colors.green,),
                                    Text("Online", style: TextStyle(
                            color: Colors.grey
                           ),),
                                 ],
                               ),
                              
                           Text("Age: 25", style: TextStyle(
                            color: Colors.white
                           ),)
                             ],
                           )
                      ],
                    ),
                  ),
                )), ),
          ),
          Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: Align(
              alignment: const Alignment(0, 1.0),
              child: _currentAd,
            ),
          )
        ],
      ),
    );
  }
}

class Screen2 extends StatelessWidget {
  const Screen2({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Tab 2 Content'),
    );
  }
}

class Screen3 extends StatelessWidget {
  const Screen3({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Tab 3 Content'),
    );
  }
}

class Screen4 extends StatelessWidget {
  const Screen4({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Tab 4 Content'),
    );
  }
}
