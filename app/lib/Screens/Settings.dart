import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/Providers/auth_provider.dart';

class Settings extends StatefulWidget { 
  const Settings({Key? key}) : super(key: key); 
  
  @override 
  State<Settings> createState() => _SettingsState(); 
}


class _SettingsState extends State<Settings> {

  // TODO add counter logic
  int inviteCount = 3;

  void _logout() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.googleLogout();
    // TODO add logout logic
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Change Username"),
              onTap: () {
                Navigator.pushNamed(context, '/change_username');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("Change Password"),
              onTap: () {
                Navigator.pushNamed(context, '/change_password');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.group),
              title: Row(
                children: [
                  const Text('Group Invites'),
                  inviteCount > 0
                   ? Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          '$inviteCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ) : Container(),
                ],
              ),
              onTap: () {
                Navigator.pushNamed(context, '/group_invites');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
