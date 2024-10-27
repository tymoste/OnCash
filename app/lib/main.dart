import 'package:flutter/material.dart'; 
import 'package:app/Screens/Login.dart';
import 'package:app/Screens/Home.dart';
import 'package:app/Screens/Group.dart'; 
import 'package:app/Screens/Settings.dart';
import 'package:app/Screens/Personal.dart';

  
void main() => runApp(MaterialApp( 
      debugShowCheckedModeBanner: false, 
      initialRoute: '/login', 
      routes: {
        '/login': (context) => Login(),
        '/': (context) => Home(),
        '/group': (context) => Group(),
        '/settings': (context) => Settings(),
        '/personal': (context) => Personal(),
        }, 
));

