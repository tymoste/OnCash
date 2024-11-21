import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:app/Utils/shared_preference.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:app/Models/group.dart';

class GroupExpencesProvider extends ChangeNotifier{

  static const getGroupsApiEndpoint = 'http://46.41.136.84:5000/get_groups';
  static const createGroupApiEndpoint = 'http://46.41.136.84:5000/create_group';

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
          return true;
        }
    }
    notifyListeners();
    return false;
  } 

  Future<bool> createGroup(String jwt, String groupName) async{

    Response? response;

    try{
      response = await http.post(Uri.parse(createGroupApiEndpoint),
        headers: <String, String>{
          'Content-Type' : 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'jwt': jwt,
          'name': groupName,
        }),
      );

    }catch(e){
      print('Error ' + e.toString());
      notifyListeners();
      return false;
    }

    if(response.statusCode == 200) {
      notifyListeners();
      return true;
    }

    notifyListeners();
    return false;
  }

}
