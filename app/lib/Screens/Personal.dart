import 'package:flutter/material.dart';
import 'package:app/Utils/shared_preference.dart';
import 'package:app/Models/user.dart';
import 'package:app/Models/group.dart';

class Personal extends StatefulWidget {
  const Personal({Key? key}) : super(key: key);

  @override
  State<Personal> createState() => _PersonalState();
}

class _PersonalState extends State<Personal> {
  late Future<User> _userData;
  late Future<Group?> _privateGroup;

  @override
  void initState() {
    super.initState();
    _userData = UserPreferences().getUser();
    _privateGroup = GroupPreferences().getPrivateGroup();
  }

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
          FutureBuilder<User>(
            future: _userData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading user data'));
              } else if (!snapshot.hasData) {
                return Center(child: Text('No user data available'));
              } else {
                final user = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Center(
                    child: Container(
                      width: 200,
                      height: 100,
                      child: Text(
                        'Email: ${user.email}\nUsername: ${user.userName}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
          
          FutureBuilder<Group?>(
            future: _privateGroup,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                print(snapshot.error.toString());
                return Center(child: Text('Error loading private group data'));
              } else if (!snapshot.hasData || snapshot.data == null) {
                return Center(child: Text('No private group data available'));
              } else {
                final privateGroup = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Center(
                    child: Container(
                      width: 200,
                      height: 100,
                      child: Text(
                        'Private Group: ID: ${privateGroup.id}\n${privateGroup.name}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

}