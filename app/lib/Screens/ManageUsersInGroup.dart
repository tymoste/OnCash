import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/group.dart';
import '../Models/user.dart';
import '../Models/otherUser.dart';
import '../Utils/shared_preference.dart';
import '../Providers/group_expences_provider.dart';

class Manageusersingroup extends StatefulWidget {
  const Manageusersingroup({super.key});

  @override
  State<Manageusersingroup> createState() => _ManageusersingroupState();
}

class _ManageusersingroupState extends State<Manageusersingroup> {

  late Future<User> _userData;
  

  @override
  void initState() {
    super.initState();
    _userData = UserPreferences().getUser();
  }

  Future<void> _showAddUserDialog(BuildContext context, String groupId) async {
    final TextEditingController emailController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add User to Group'),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Enter user email',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isNotEmpty) {
                  final provider = Provider.of<GroupExpencesProvider>(context, listen: false);
                  final jwt = await UserPreferences().getUser().then((user) => user.jwt);
                  final success = await provider.addUserToGroup(jwt, groupId, email);

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User invited!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to invite user.')),
                    );
                  }
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    Object? args = ModalRoute.of(context)!.settings.arguments;
    if (args == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Group Screen')),
        body: Center(
          child: Text('Brak przekazanych argumentów'),
        ),
      );
    }
    args = args as Map<String, dynamic>;
    String group_id = args['group_id'].toString();
    String group_name = args['group_name'].toString();

    // Call to the provider to fetch users from provider field
    final usersInGroupProvider = Provider.of<GroupExpencesProvider>(context, listen: false);
    _userData.then((data) async {
        await usersInGroupProvider.getUsersInGroupFromServer(
          data.jwt,
          group_id,
        );
    });

   return Scaffold(
      appBar: AppBar(
        title: Text('${group_name}\'s members'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
          Navigator.of(context).pop();
        },
      ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showAddUserDialog(context, group_id);
              //Navigator.pushNamed(context, '/');
            },
          ),
        ],
      ),


      body: Consumer<GroupExpencesProvider>(
        builder: (context, provider, child) {
          final users = provider.users;
          print(users.toString());
          if (users.isEmpty) {
            return Center(child: Text('No users available.'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: Icon(Icons.person),
                title: Text(user.userName),
                subtitle: Text(user.email),
              );
            },
          );
        },
      ),
    );
  }
}