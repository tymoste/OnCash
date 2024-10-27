import 'package:flutter/material.dart';
import 'package:app/Screens/Group.dart'; 
import 'package:app/Screens/Settings.dart';
import 'package:app/Screens/Personal.dart';

class Home extends StatefulWidget { 
  const Home({Key? key}) : super(key: key); 
  
  @override 
  State<Home> createState() => _HomeState(); 
}


class _HomeState extends State<Home>{
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final List<Widget> _screens = [
      const Personal(),
      const Group(),
      const Settings(),
    ];

    void onTabTapped(int index) {
      setState(() {
        _currentIndex = index;
      });
  }

      return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Personal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Group',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text('Home'),
    //     centerTitle: true,
    //     automaticallyImplyLeading: false,
    //   ),
    //   body: Column(
    //     children: <Widget>[
    //       Padding(
    //         padding: const EdgeInsets.only(top: 30.0),
    //         child: Center(
    //           child: Container(
    //             width: 200,
    //             height: 100,
    //             child: const Text('Recieved data'),
    //           ),
    //         )
    //       ),
    //       Padding(
    //         padding: const EdgeInsets.only(top: 30.0),
    //         child: Center(
    //           child: Container(
    //             width: 200,
    //             height: 100,
    //             child: Text(args['email']),
    //           ),
    //         )
    //       ),

    //     ],
    //   ),
    // );

  }
}