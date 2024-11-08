import 'package:flutter/material.dart';

class GroupInvites extends StatefulWidget {
  const GroupInvites({super.key});

  @override
  State<GroupInvites> createState() => _GroupInvitesState();
}

class _GroupInvitesState extends State<GroupInvites> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group invites'),
      ),
      body: Center(
        child: const Text('Group invites screen'),
      ),
    );
  }
}