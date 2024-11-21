import 'package:flutter/material.dart';
import 'package:app/Models/group.dart';
import 'package:app/Utils/shared_preference.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({super.key});

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  late Future<List<Group>> _publicGroups;

  @override
  void initState() {
    super.initState();
    _publicGroups = GroupPreferences().getPublicGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Groups'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/create_group');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Group>>(
        future: _publicGroups,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No groups available'));
          } else {
            List<Group> groups = snapshot.data!;

            return ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) { //Individual element
                Group group = groups[index];
                return ListTile(
                  title: Text(group.name), // Display group name
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Navigate to specific group with its id
                      Navigator.pushNamed(
                        context,
                        '/group_details',
                        arguments: group.id, // Pass the group id as argument
                      );
                    },
                    child: Text('Go'),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
