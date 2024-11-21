import 'package:app/Models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/Models/group.dart';
import 'dart:convert';

class UserPreferences {

  void saveUser(User user) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', user.userName);
    prefs.setString('email', user.email);
    prefs.setString('jwt', user.jwt);
  }

  Future<User> getUser() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email') ?? '';
    String? userName = prefs.getString('username') ?? '';
    String? jwt = prefs.getString('jwt') ?? '';
    return User(userName: userName, email: email, jwt: jwt);
  }

  void changeUsername(String username) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', username);
  }

}

class GroupPreferences { 

  // Save list of groups to SharedPreferences
  void savePublicGroups(List<Group> groups) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    List<String> groupsJson = groups.map((group) => json.encode({
      'id': group.id,
      'name': group.name,
      'private': group.private,
    })).toList();

    // Save the list of JSON strings as a single string
    prefs.setStringList('groups', groupsJson);
  }

  // Save private group to Shared Preferences
  void savePrivateGroup(Group privateGroup) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String group = json.encode({
      'id': privateGroup.id,
      'name': privateGroup.name,
      'private': privateGroup.private,
    });
    prefs.setString('privateGroup', group);
  }

  // Retrieve the list of groups from SharedPreferences
  Future<List<Group>> getPublicGroups() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get the list of JSON strings stored in SharedPreferences
    List<String>? groupsJson = await prefs.getStringList('groups');

    if (groupsJson == null) {
      return [];
    }

    // Convert the list of JSON strings back to a list of Group objects
    List<Group> groups = groupsJson
        .map((jsonString) => Group.fromJson(json.decode(jsonString)))
        .toList();
    return groups;
  }

  // Retrive private group from SharedPReferences
  Future<Group> getPrivateGroup() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String privateGroup = prefs.getString('privateGroup') ?? '';
    return Group.fromJson(json.decode(privateGroup));
  }

}
