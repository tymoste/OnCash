import 'dart:convert';

import 'package:app/Models/user.dart';
import 'package:flutter/material.dart';
import 'package:app/Models/group.dart';
import 'package:app/Utils/shared_preference.dart';
import 'package:provider/provider.dart';
import 'package:app/Providers/group_expences_provider.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({super.key});

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  late Future<List<Group>> _publicGroups;
  User? userData;

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
              itemBuilder: (context, index) {
                Group group = groups[index];
                return ListTile(
                  leading: ClipOval(
                    child: Image.memory(
                      base64Decode(group.base64Img),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(group.name),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/group_spendings',
                        arguments: {
                          "group_id": group.id,
                          "group_name": group.name,
                        },
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
