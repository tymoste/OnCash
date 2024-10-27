import 'package:flutter/material.dart'; 

class Settings extends StatefulWidget { 
  const Settings({Key? key}) : super(key: key); 
  
  @override 
  State<Settings> createState() => _SettingsState(); 
}


class _SettingsState extends State<Settings>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Center(
              child: Container(
                width: 200,
                height: 100,
                child: const Text('Settings Screen'),
              ),
            )
          ),
        ],
      ),
    );

  }
}