import 'package:app/Providers/group_expences_provider.dart';
import 'package:app/Utils/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/Providers/auth_provider.dart';

class Settings extends StatefulWidget { 
  const Settings({Key? key}) : super(key: key); 
  
  @override 
  State<Settings> createState() => _SettingsState(); 
}

class _SettingsState extends State<Settings> {

@override
void initState() {
  super.initState();
  _fetchGroupInvites(); // Call the async method
}

Future<void> _fetchGroupInvites() async {
  final jwt = await getJwt(); // Wait for the JWT
  if (jwt.isNotEmpty) {
    Provider.of<GroupExpencesProvider>(context, listen: false).getGroupInvites(jwt);
  }
}

Future<String> getJwt() async {
  return await UserPreferences().getUser().then((user) => user.jwt);
}

  void _logout() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.loggedInStatus == Status.GoogleLoggedIn) {
      authProvider.googleLogout();
    } else if (authProvider.loggedInStatus == Status.LoggedIn) {
      authProvider.logout();
    }
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
            Consumer<GroupExpencesProvider>(
              builder: (context, groupProvider, _) {
                final inviteCount = groupProvider.invites.length;
                return ListTile(
                  leading: const Icon(Icons.group),
                  title: Row(
                    children: [
                      const Text('Group Invites'),
                      inviteCount > 0
                          ? Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
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
                            )
                          : Container(),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/group_invites');
                  },
                );
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
