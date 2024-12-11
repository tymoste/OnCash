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
  User? userData;
  List<Group>? groupData;

  @override
  void initState() {
    super.initState();
    loadUser();
    loadGroup();
  }

  Future<void> loadUser() async {
    userData = await UserPreferences().getUser();
    setState(() {});
  }

  Future<void> loadGroup() async {
    groupData = await GroupPreferences().getPublicGroups();
    setState(() {});
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
    // Check if userData and groupData are loaded
    if (userData == null || groupData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Loading...'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Set current group based on passed group_id
    String group_id = (ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>)['group_id'].toString();

    final currentGroup = groupData!.firstWhere(
        (group) => group.id.toString() == group_id, orElse: () => Group());

    // Call to the provider to fetch users in the group
    final usersInGroupProvider = Provider.of<GroupExpencesProvider>(context, listen: false);
    usersInGroupProvider.getUsersInGroupFromServer(userData!.jwt, group_id);

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentGroup.name}\'s members'),
        centerTitle: true,
        actions: [
          if (currentGroup.isAdmin)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                _showAddUserDialog(context, group_id);
              },
            ),
        ],
      ),
      body: Consumer<GroupExpencesProvider>(
        builder: (context, provider, child) {
          final users = provider.users;
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
            trailing: currentGroup.isAdmin && user.email != userData!.email  // Ensure the user is not removing themselves
                ? IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      // Confirm delete action
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Remove User"),
                            content: Text("Are you sure you want to remove ${user.userName} from the group?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close dialog
                                },
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final jwt = await UserPreferences().getUser().then((user) => user.jwt);
                                  Provider.of<GroupExpencesProvider>(context, listen: false)
                                      .deleteUserFromGroup(jwt, user.userID, int.parse(group_id));
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Remove"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  )
                : null, // If not an admin or trying to remove themselves, don't show button
          );
        },
      );
        },
      ),
    );
  }
}
