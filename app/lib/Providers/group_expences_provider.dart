import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:app/Models/expence.dart';
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
  static const acceptInviteApiEndpoint = 'http://46.41.136.84:5000/accept_invite';
  static const declineInviteApiEndpoint = 'http://46.41.136.84:5000/decline_invite';
  static const addNewGroupCategoryEndpoint = 'http://46.41.136.84:5000/add_category';
  static const getGroupCategoriesEndpoint = 'http://46.41.136.84:5000/get_categories'; 
  static const addExpenseToGroupEndpoint = 'http://46.41.136.84:5000/add_expense';
  static const getExpensesFromGroupEndpoint = 'http://46.41.136.84:5000/get_expenses';
  static const deleteExpenseFromGroupEndpoint = 'http://46.41.136.84:5000/delete_expense';
  static const deleteUserFromGroupEndpoint = 'http://46.41.136.84:5000/delete_user';

  late List<Map<String, dynamic>> _invites = [];
  List<Map<String, dynamic>> get invites => _invites;

  late List<otherUser> _users = [];
  List<otherUser> get users => _users;

  Future<bool> declineInvite(String jwt, String inviteId) async{
    try {
      final response = await http.post(
        Uri.parse(declineInviteApiEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'jwt': jwt,
          'invite_id': inviteId,
        }),
      );

      if (response.statusCode == 200) {
        // Refresh invites after successful acceptance
        await getGroupInvites(jwt);
        notifyListeners();
        return true;
      } else {
        print('Failed to decline invite: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error declining invite: $e');
      return false;
    }
  }

  Future<bool> acceptInvite(String jwt, String inviteId) async {

  try {
    final response = await http.post(
      Uri.parse(acceptInviteApiEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'jwt': jwt,
        'invite_id': inviteId,
      }),
    );

    if (response.statusCode == 200) {
      // Refresh invites after successful acceptance
      await getGroupInvites(jwt);
      await getUserGroups(jwt);
      notifyListeners();
      return true;
    } else {
      print('Failed to accept invite: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Error accepting invite: $e');
    return false;
  }
}

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
              'Connection': 'Keep-Alive',
              'Accept-Encoding': 'gzip, deflate, br',
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

  Future<bool> createGroup(String jwt, String groupName, File groupImg) async {

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
      //print(response.body); generating errors
      await getUserGroups(jwt);
      notifyListeners();
      return true;
    }

    notifyListeners();
    return false;
  }

  Future<bool> getUsersInGroupFromServer(String jwt, String groupId) async {

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

  Future<bool> addNewGroupCategory(String jwt, String groupId, String categoryName) async {

    Response? response;
    try{
        response = await http.post(Uri.parse(addNewGroupCategoryEndpoint),
        headers: <String, String>{
          'Content-Type' : 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'jwt': jwt,
          'group_id': groupId,
          'name': categoryName
        }),
      );
    }catch(e){
      print('Error ' + e.toString());
      notifyListeners();
      return false;
    }

    if(response.statusCode == 200){
      notifyListeners();
      return true;
    }

    notifyListeners();
    return false;
  }

  Future<List<Map<String, dynamic>>> getGroupCategories(String jwt, String groupId) async {
    Response? response;
    try {
          response = await http.post(Uri.parse(getGroupCategoriesEndpoint),
          headers: <String, String>{
            'Content-Type' : 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'jwt': jwt,
            'group_id': groupId,
          }),
    );
    } catch (e) {
      print('Error: ' + e.toString());
      return [];
    }

    if (response.statusCode == 200) {
        var responseJson = jsonDecode(response.body);
        List<dynamic> categoriesJson = responseJson['categories'];
        
        List<Map<String, dynamic>> categories = categoriesJson
            .map((category) => {
                  'category_id': category['category_id'],
                  'category_name': category['category_name']
                })
            .toList();
        return categories;
      } else {
        return [];
    }
  }

  Future<bool> addExpenseToGroup(String jwt, String groupId, String categoryId, double price, String description, String expenceName) async {
    
    Response? response;
        try{
        response = await http.post(Uri.parse(addExpenseToGroupEndpoint),
        headers: <String, String>{
          'Content-Type' : 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'jwt': jwt,
          'group_id': groupId,
          'name': expenceName,
          'price': price,
          'description': description,
          'category_id': categoryId
        }),
      );
    }catch(e){
      print('Error ' + e.toString());
      notifyListeners();
      return false;
    }

    if(response.statusCode == 200){
      notifyListeners();
      return true;
    }

    notifyListeners();
    return false;
  }

Future<List<Expence>> getExpensesFromGroup(String jwt, String groupId) async {
    
    Response? response;
        try{
        response = await http.post(Uri.parse(getExpensesFromGroupEndpoint),
        headers: <String, String>{
          'Content-Type' : 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'jwt': jwt,
          'group_id': groupId,
        }),
      );
    }catch(e){
      print('Error ' + e.toString());
      notifyListeners();
      return [];
    }

    if(response.statusCode == 200){
      final Map<String, dynamic> responseData = json.decode(response!.body);
      List<dynamic> expencesList = responseData['expenses'];
      notifyListeners();
      return expencesList.map((expencesList) => Expence.fromJson(expencesList)).toList();
    }

    notifyListeners();
    return [];
  }

Future<bool> deleteUserFromGroup(String jwt, int userId, int groupId) async {

    Response? response;
    try{
        response = await http.post(Uri.parse(deleteUserFromGroupEndpoint),
        headers: <String, String>{
          'Content-Type' : 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'jwt': jwt,
          'group_id': groupId,
          'user_id': userId
        }),
      );
    }catch(e){
      print('Error ' + e.toString());
      notifyListeners();
      return false;
    }

    if(response.statusCode == 200){
      notifyListeners();
      return true;
    }

    notifyListeners();
    return false;

}

Future<bool> deleteExpenseFromGroup(String jwt, int expenseId) async {

    Response? response;
    try{
        response = await http.post(Uri.parse(deleteExpenseFromGroupEndpoint),
        headers: <String, String>{
          'Content-Type' : 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'jwt': jwt,
          'expense_id': expenseId
        }),
      );
    }catch(e){
      print('Error ' + e.toString());
      notifyListeners();
      return false;
    }

    if(response.statusCode == 200){
      notifyListeners();
      return true;
    }

    notifyListeners();
    return false;

}


}
