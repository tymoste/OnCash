import 'package:flutter/material.dart'; 

class Group extends StatefulWidget { 
  const Group({Key? key}) : super(key: key); 
  
  @override 
  State<Group> createState() => _GroupState(); 
}


class _GroupState extends State<Group>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group'),
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
                child: const Text('Group Screen'),
              ),
            )
          ),
        ],
      ),
    );

  }
}