import 'package:flutter/material.dart';

class GroupInvites extends StatefulWidget {
  const GroupInvites({super.key});

  @override
  State<GroupInvites> createState() => GroupInvitesState();
}

class GroupInvitesState extends State<GroupInvites> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change username'),
      ),
      body: Center(
        child: const Text('Change username screen'),
      ),
    );
  }
}