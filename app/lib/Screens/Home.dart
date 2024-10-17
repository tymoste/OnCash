import 'package:flutter/material.dart'; 

class Home extends StatefulWidget { 
  const Home({Key? key}) : super(key: key); 
  
  @override 
  State<Home> createState() => _HomeState(); 
}


class _HomeState extends State<Home>{

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
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
                child: const Text('Recieved data'),
              ),
            )
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Center(
              child: Container(
                width: 200,
                height: 100,
                child: Text(args['email']),
              ),
            )
          )
        ],
      ),
    );

  }
}