import 'package:flutter/material.dart'; 
import 'package:app/screen/login.dart'; 
  
void main() => runApp(MaterialApp( 
      debugShowCheckedModeBanner: false, 
      initialRoute: '/login', 
      routes: {
        '/login': (context) => Login()
        }, 
));

