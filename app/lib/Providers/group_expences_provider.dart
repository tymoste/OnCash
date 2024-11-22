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
  
  late List<otherUser> _users = [];
  List<otherUser> get users => _users;

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



  // Future<List<User>> getUsersInGroup() async{
  //   return users;
  // }

}
