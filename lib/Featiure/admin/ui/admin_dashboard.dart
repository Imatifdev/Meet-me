
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meetly/Featiure/admin/models/fake_user.dart';
import 'package:meetly/Featiure/admin/ui/add_fake_user_screen.dart';


class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  AdminDashboardState createState() => AdminDashboardState();
}

class AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin{
  final List<Widget> _tabs = [
    const UsersTab(),
    const ChatTab(),
  ];
  late TabController controller ;

  @override
  void initState() {
    
    controller = TabController(length: 2, vsync: this);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        bottom: TabBar(
          controller: controller,
          tabs: const [
            Tab(text: 'Users'),
            Tab(text: 'Chats'),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller,
        children: _tabs,
      ),
    );
  }
}

class UsersTab extends StatefulWidget {
  const UsersTab({super.key});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  //   BannerAd? _bannerAd;
  //   //fb ad
  //   Widget _currentAd = SizedBox(
  //   width: 0.0,
  //   height: 0.0,
  // );

  //   @override
  // void initState() {
  // //   FacebookAudienceNetwork.init(
  // //   testingId: "c4b5f429-5e2f-487b-8fe1-430d4f209b99",
  // // );
  //   FacebookAudienceNetwork.init(
  //       testingId: "aa3ba621-b601-4f89-9a01-d4e36cfe43eb"); 
  //   _showBannerAd();
  //   BannerAd(
  //   adUnitId: AdHelper.bannerAdUnitId,
  //   request: const AdRequest(),
  //   size: AdSize.banner,
  //   listener: BannerAdListener(
      
  //     onAdLoaded: (ad) {
  //       setState(() {
  //         _bannerAd = ad as BannerAd;
  //       });
  //     },
  //     onAdFailedToLoad: (ad, err) {
  //       print('Failed to load a banner ad: ${err.message}');
  //       ad.dispose();
  //     },
  //   ),
  // ).load();
  //   super.initState();
  // }

  // //fb
  // _showBannerAd() {
  //   setState(() {
  //     _currentAd = FacebookBannerAd(
  //       // placementId: "YOUR_PLACEMENT_ID",
  //       placementId: "3547050492249770_3547050788916407", //testid
  //       //size of banner ad
  //       bannerSize: BannerSize.STANDARD,
  //       listener: (result, value) {
  //         print("Banner Ad: $result -->  $value");
  //       },
  //     );
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //  if (_bannerAd != null)
        //     SizedBox(
        //       //width:MediaQuery.of(context).size.width,
        //       height: _bannerAd!.size.height.toDouble(),
        //       child: AdWidget(ad: _bannerAd!),
        //     ),
        //     SizedBox(height: 10,),
            
        //     FacebookBannerAd(
        //       placementId: Platform.isAndroid ? "3547050492249770_3547050788916407" : "1698061277334331_1698061574000968",
        //       bannerSize: BannerSize.STANDARD,
        //       listener: (result, value) {
        //         switch (result) {
        //           case BannerAdResult.ERROR:
        //             print("Error: $value");
        //             break;
        //           case BannerAdResult.LOADED:
        //             print("Loaded: $value");
        //             break;
        //           case BannerAdResult.CLICKED:
        //             print("Clicked: $value");
        //             break;
        //           case BannerAdResult.LOGGING_IMPRESSION:
        //             print("Logging Impression: $value");
        //             break;
        //         }
        //       },
        //     ),
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
        StreamBuilder<QuerySnapshot>(
        // Replace 'users' with your Firestore collection name
        stream: FirebaseFirestore.instance.collection('fakeUsers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Loading indicator
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
        
          // If we reach here, we have data
          final List<FakeUser> users = snapshot.data!.docs
              .map((doc) => FakeUser.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
        
          return Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text('${user.firstName} ${user.lastName}'),
                  subtitle: Text('Age: ${user.age} | Status: ${user.status}'),
                  // leading: CircleAvatar(
                  //   backgroundImage: NetworkImage(user.imgUrl),
                  // ),
                );
              },
            ),
          );
        },
            ),
        // Flexible(
        //   fit: FlexFit.tight,
        //   flex: 1,
        //   child: Align(
        //     alignment: const Alignment(0, 1.0),
        //     child: _currentAd,
        //   ),
        // )
      ],
    );
  }
}

class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) => const Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage("https://images.unsplash.com/photo-1463453091185-61582044d556?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=870&q=80"),  
            ),
            title: Text("User's Name", style: TextStyle(color: Colors.black),),
            subtitle: Text("Last Messge", style: TextStyle(color: Colors.grey),),
          ),
          Divider()
        ],
      ),
      itemCount: 20,
    );
  }
}

