import 'package:flutter/material.dart'; 

class Personal extends StatefulWidget { 
  const Personal({Key? key}) : super(key: key); 
  
  @override 
  State<Personal> createState() => _PersonalState(); 
}


class _PersonalState extends State<Personal>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal'),
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
                child: const Text('Personal Screen'),
              ),
            )
          ),
        ],
      ),
    );

  }
}