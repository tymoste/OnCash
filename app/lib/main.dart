import 'package:flutter/material.dart'; 
import 'package:app/Screens/Login.dart';
import 'package:app/Screens/Home.dart'; 
  
void main() => runApp(MaterialApp( 
      debugShowCheckedModeBanner: false, 
      initialRoute: '/login', 
      routes: {
        '/login': (context) => Login(),
        '/': (context) => Home()
        }, 
));

