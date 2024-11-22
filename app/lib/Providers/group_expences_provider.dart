import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:app/Utils/shared_preference.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:app/Models/group.dart';

import '../Models/user.dart';
import '../Models/otherUser.dart';

class GroupExpencesProvider extends ChangeNotifier{

  static const getGroupsApiEndpoint = 'http://46.41.136.84:5000/get_groups';
  static const createGroupApiEndpoint = 'http://46.41.136.84:5000/create_group';
  static const getUsersInGroupApiEndpoint = 'http://46.41.136.84:5000/get_users';
  static const addUserToGroupApiEndpoint = 'http://46.41.136.84:5000/invite';
  static const getInvitesApiEndpoint = 'http://46.41.136.84:5000/get_invites';

  late List<Map<String, dynamic>> _invites = [];
  List<Map<String, dynamic>> get invites => _invites;

  late List<otherUser> _users = [];
  List<otherUser> get users => _users;


  Future<bool> getGroupInvites(String jwt) async {
    try {
      final response = await http.post(
        Uri.parse(getInvitesApiEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'jwt': jwt,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData["error"] == "no error") {
          // Creating list of pending invites
          List<dynamic> invitesList = responseData['invites'];
          _invites = invitesList.map((invite) => invite as Map<String, dynamic>).toList();
          notifyListeners();
          return true;
        } else {
          print('Server error: ${responseData["error"]}');
          return false;
        }
      } else {
        print('Failed to fetch invites: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error fetching invites: $e');
      return false;
    }
  }


  Future<bool> addUserToGroup(String jwt, String groupId, String email) async {

    try {
      final response = await http.post(
        Uri.parse(addUserToGroupApiEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'jwt': jwt,
          'group_id': groupId,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        // Update the user list
        print("\n\n\n\n\n\n${response.body}\n\n\n\n\n");
        await getUsersInGroupFromServer(jwt, groupId);
        notifyListeners();
        return true;
      } else {
        print('Failed to add user: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error adding user to group: $e');
      return false;
    }
  }

  Future<bool> getUserGroups(String jwt) async {

      Response? response;
      int attempts = 0;
      const int maxAttempts = 5;

      while(attempts < maxAttempts) {
        attempts++;

        try{
          response = await http.post(Uri.parse(getGroupsApiEndpoint),
            headers: <String, String>{
              'Content-Type' : 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'jwt': jwt,
            }),
          );

        }catch(e){
          print('Error ' + e.toString());
          notifyListeners();
          return false;
        }

        if(response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response!.body);
          
          //conver groups from response to List
          List<dynamic> groupsJson = responseData['groups'];
          List<Group> groups = groupsJson.map((groupsJson) => Group.fromJson(groupsJson)).toList();
          
          //Extracting private group for future simplicity (there will be always only one private group)
          Group privateGroup = groups.firstWhere((group) => group.private);
          groups = groups.where((element) => element.private == false).toList();

          //save group list and private group to shared preferences
          GroupPreferences().savePublicGroups(groups);
          GroupPreferences().savePrivateGroup(privateGroup);

          notifyListeners();
          print(response.body);
          print(privateGroup.name);
          return true;
        }
    }
    notifyListeners();
    return false;
  } 

  Future<bool> createGroup(String jwt, String groupName, File groupImg) async{

    var response;
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(createGroupApiEndpoint),
    );
    request.fields['jwt'] = jwt;
    request.fields['name'] = groupName;
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      groupImg.path,
    ));

    try{
      response = await request.send();

    }catch(e){
      print('Error ' + e.toString());
      notifyListeners();
      return false;
    }

    if(response.statusCode == 200) {
      print(response.body);
      notifyListeners();
      return true;
    }

    notifyListeners();
    return false;
  }

  Future<bool> getUsersInGroupFromServer(String jwt, String groupId) async{

    Response? response;
    try{
      response = await http.post(Uri.parse(getUsersInGroupApiEndpoint),
        headers: <String, String>{
          'Content-Type' : 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'jwt': jwt,
          'group_id': groupId
        }),
      );
    }catch(e){
      print('Error ' + e.toString());
      notifyListeners();
      return false;
    }

    if(response.statusCode == 200) {
      print(response.body);

      final Map<String, dynamic> responseData = json.decode(response!.body);
          
      //convert users from response to List
      List<dynamic> usersJson = responseData['users'];
      _users = usersJson.map((usersJson) => otherUser.fromJson(usersJson)).toList();
      _users.forEach((element) => 
        print(element.userName),
      );
      
      //save user list to shared preferences
      //GroupPreferences().saveUsersToPublicGroup(groupId, users);

      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

}
