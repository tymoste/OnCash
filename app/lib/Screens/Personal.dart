import 'package:flutter/material.dart';
import 'package:app/Utils/shared_preference.dart';
import 'package:app/Models/user.dart';

class Personal extends StatefulWidget {
  const Personal({Key? key}) : super(key: key);

  @override
  State<Personal> createState() => _PersonalState();
}

class _PersonalState extends State<Personal> {
  late Future<User> _userData;

  @override
  void initState() {
    super.initState();
    _userData = UserPreferences().getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<User>(
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
            return Column(
              children: <Widget>[
                Padding(
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
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
