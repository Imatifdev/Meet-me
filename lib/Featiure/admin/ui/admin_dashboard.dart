import 'package:flutter/material.dart';

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

class UsersTab extends StatelessWidget {
  const UsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Total Users: 10", style: TextStyle(fontSize: 18, ),),
          ),
          IconButton(onPressed: (){}, icon: const Icon(Icons.add_box_rounded, size: 40,))
        ],),
        Expanded(
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
        )
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

