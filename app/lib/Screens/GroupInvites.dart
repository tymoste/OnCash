import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/group_expences_provider.dart';
import '../Utils/shared_preference.dart';

class GroupInvites extends StatefulWidget {
  const GroupInvites({super.key});

  @override
  State<GroupInvites> createState() => GroupInvitesState();
}

class GroupInvitesState extends State<GroupInvites> {
  Future<void>? _fetchInvites;

  @override
  void initState() {
    super.initState();
    _fetchInvites = _loadInvites();
  }

  Future<void> _loadInvites() async {
    final jwt = await UserPreferences().getUser().then((user) => user.jwt);
    final provider = Provider.of<GroupExpencesProvider>(context, listen: false);
    await provider.getGroupInvites(jwt);

    for (var invite in provider.invites) {
      await provider.getGroupInfo(jwt, invite['group_id'].toString());
    }
  }

  Future<void> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      onConfirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending invites'),
      ),
      body: FutureBuilder<void>(
        future: _fetchInvites,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading invites: ${snapshot.error}'));
          }

          return Consumer<GroupExpencesProvider>(
            builder: (context, provider, child) {
              final invites = provider.invites;
              if (invites.isEmpty) {
                return const Center(child: Text('No pending invites.'));
              }

              return ListView.builder(
                itemCount: invites.length,
                itemBuilder: (context, index) {
                  final invite = invites[index];
                  final groupInfo = provider.groupInfo[invite['group_id'].toString()];

                  return ListTile(
                    leading: groupInfo != null && groupInfo['group_img'] != null
                        ? CircleAvatar(
                            backgroundImage: MemoryImage(
                              const Base64Decoder().convert(groupInfo['group_img']!),
                            ),
                          )
                        : const Icon(Icons.group),
                    title: groupInfo != null
                        ? Text(groupInfo['group_name'] ?? 'Group ID: ${invite['group_id']}')
                        : Text('Group ID: ${invite['group_id']}'),
                    //subtitle: Text('Invite ID: ${invite['invite_id']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            _showConfirmationDialog(
                              context,
                              title: 'Accept Invite',
                              content: 'Are you sure you want to accept this invite?',
                              onConfirm: () async {
                                final provider = Provider.of<GroupExpencesProvider>(context, listen: false);
                                final jwt = await UserPreferences().getUser().then((user) => user.jwt);

                                final success = await provider.acceptInvite(jwt, invite['invite_id'].toString());
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Invite accepted successfully')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Failed to accept invite')),
                                  );
                                }
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            _showConfirmationDialog(
                              context,
                              title: 'Reject Invite',
                              content: 'Are you sure you want to reject this invite?',
                              onConfirm: () async {
                                final provider = Provider.of<GroupExpencesProvider>(context, listen: false);
                                final jwt = await UserPreferences().getUser().then((user) => user.jwt);

                                final success = await provider.declineInvite(jwt, invite['invite_id'].toString());
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Invite declined successfully')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Failed to declined invite')),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
