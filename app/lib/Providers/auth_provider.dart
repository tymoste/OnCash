import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:app/Models/user.dart';
import 'package:app/Utils/shared_preference.dart';
import 'package:crypt/crypt.dart';

enum Status {
  LoggedIn,
  NotLoggedIn,
  UserExists,
  Registered,
  ServerError,
  UsernameAlreadyExists,
  PasswordAlreadyExists,

}

class AuthProvider extends ChangeNotifier{
  Status _loggedInStatus = Status.NotLoggedIn;

  Status get loggedInStatus => _loggedInStatus;

  set loggedInStatus(Status value){
    _loggedInStatus = value;
  }

  static const loginApiEndpoint = 'http://46.41.136.84:5000/login';
  static const registerApiEndpoint = 'http://46.41.136.84:5000/register';
  static const changeUsernameApiEndpoint = 'http://46.41.136.84:5000/change_username';
  static const changePasswordApiEndpoint = 'http://46.41.136.84:5000/change_password';

  Future<bool> register(String email, String password, String userName) async {
    Response? response;
    try{
      response = await http.post(Uri.parse(registerApiEndpoint),
      headers: <String, String>{
        'Content-Type' : 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': userName,
        // 'password': Crypt.sha256(password).toString(),
        'password': password,
        'email' : email,
      }),
      );

    }catch (e){
      print('Error ' + e.toString());
      return false;
    }

    if(response?.statusCode == 400){
      //todo
      _loggedInStatus = Status.UserExists;
      return false;
    }

    if(response?.statusCode == 200){
        _loggedInStatus = Status.Registered;
        return true;
    }
    _loggedInStatus = Status.ServerError;
    return false;
  }  

  Future<bool> login(String email, String password) async {
      Response? response;

      try{
        response = await http.post(Uri.parse(loginApiEndpoint),
        headers: <String, String>{
          'Content-Type' : 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': email,
          // 'password': Crypt.sha256(password).toString(),
          'password': password,
        }),
        );
      }catch(e){
        print('Error ' + e.toString());
        return false;
      }
    
      if(response?.statusCode == 200){
        //Add to SharedPreferences
        final Map<String, dynamic> responseData = json.decode(response!.body);
        print(responseData);

        User authUser = User.fromJson(responseData);
        print(authUser.toString());
        UserPreferences().saveUser(authUser);
        _loggedInStatus = Status.LoggedIn;
        notifyListeners();
        return true;
      }else{
        _loggedInStatus = Status.NotLoggedIn;
        notifyListeners();
        return false;
      }
  }

  Future<bool> changeUsername(String jwt, String newUsername, String password) async{
    Response? response;

    try{
      response = await http.post(Uri.parse(changeUsernameApiEndpoint),
      headers: <String, String>{
        'Content-Type' : 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'jwt': jwt,
        'newUsername': newUsername,
        // 'password': Crypt.sha256(password).toString(),
        'password': password,
      }),
      );
    }catch(e){
      print('Error ' + e.toString());
      return false;
    }
  
    if(response?.statusCode == 200){
      //actualise to SharedPreferences

      UserPreferences().changeUsername(newUsername);
      //final Map<String, dynamic> responseData = json.decode(response!.body);
      //print(responseData);
      //User actualisedUser = User.fromJson(responseData);
      //User prevUser = UserPreferences().getUser() as User;
      //prevUser.userName = actualisedUser.userName;
      notifyListeners();
      return true;
    }else{
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(String jwt, String oldPassword, String newPassword) async{
    Response? response;

    try{
      response = await http.post(Uri.parse(changePasswordApiEndpoint),
      headers: <String, String>{
        'Content-Type' : 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'jwt': jwt,
        'oldPassword': oldPassword,
        // 'password': Crypt.sha256(password).toString(),
        'newPassword': newPassword,
      }),
      );
    }catch(e){
      print('Error ' + e.toString());
      return false;
    }
  
    if(response?.statusCode == 200){
      UserPreferences().changePassword(newPassword);
      notifyListeners();
      return true;
    }else{
      notifyListeners();
      return false;
    }
  }
}