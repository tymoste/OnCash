import 'package:app/Providers/user_provider.dart';
import 'package:flutter/material.dart'; 
import 'package:app/Screens/Login.dart';
import 'package:app/Screens/Home.dart';
import 'package:app/Screens/Group.dart'; 
import 'package:app/Screens/Settings.dart';
import 'package:app/Screens/Personal.dart';
import 'package:provider/provider.dart';
import 'package:app/Providers/auth_provider.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => UserProvider()),
    ],
    child: MaterialApp(
      title: 'OnCash',
      initialRoute: '/login',
      routes: {
        '/login': (context) => Login(),
        '/': (context) => Home(),
        '/group': (context) => Group(),
        '/settings': (context) => Settings(),
        '/personal': (context) => Personal(),
      }, 
    )
    );
  }
}

