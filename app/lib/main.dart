import 'package:app/Providers/user_provider.dart';
import 'package:app/Screens/ChangePassword.dart';
import 'package:app/Screens/ChangeUsername.dart';
import 'package:app/Screens/GroupInvites.dart';
import 'package:app/Screens/GroupList.dart';
import 'package:app/Screens/ManageUsersInGroup.dart';
import 'package:app/Screens/Register.dart';
import 'package:flutter/material.dart'; 
import 'package:app/Screens/Login.dart';
import 'package:app/Screens/Home.dart';
import 'package:app/Screens/Group.dart';
import 'package:app/Screens/CreateGroup.dart'; 
import 'package:app/Screens/Settings.dart';
import 'package:app/Screens/Personal.dart';
import 'package:app/Screens/Register.dart';
import 'package:provider/provider.dart';
import 'package:app/Providers/auth_provider.dart';
import 'package:app/Providers/group_expences_provider.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => GroupExpencesProvider()),
    ],
    child: MaterialApp(
      title: 'OnCash',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login', //login
      routes: {
        '/login': (context) => Login(),
        '/': (context) => Home(),
        '/group': (context) => GroupListScreen(),
        '/settings': (context) => Settings(),
        '/personal': (context) => Personal(),
        '/register': (context) => Register(),
        '/change_username': (context) => ChangeUsername(),
        '/change_password': (context) => ChangePassword(),
        '/group_invites': (context) => GroupInvites(),
        '/group_spendings': (context) => const GroupScreen(),
        '/create_group' : (context) => GroupCreate(),
        '/get_users_in_group' : (context) => Manageusersingroup(),
      }, 
    )
    );
  }
}

