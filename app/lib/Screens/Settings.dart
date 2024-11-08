import 'package:flutter/material.dart'; 

class Settings extends StatefulWidget { 
  const Settings({Key? key}) : super(key: key); 
  
  @override 
  State<Settings> createState() => _SettingsState(); 
}


class _SettingsState extends State<Settings>{

  //Sample invites count change with logic later
  int inviteCount = 3;

  void _logout() {
    // TODO add logic
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
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
              title: const Text("Change username"),
              onTap: () {
                Navigator.pushNamed(context, '/change_username');
                },
            ),
            Divider(),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("Change password"),
              onTap: () {
                Navigator.pushNamed(context, '/change_password');
                },
            ),
            Divider(),
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
            Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text("Logout"),
              onTap: _logout,
            )
          ],
        ),
      )
    );

  }
}