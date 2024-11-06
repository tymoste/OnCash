import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:app/Models/user.dart';
import 'package:app/Utils/shared_preference.dart';

enum Status {
  LoggedIn,
  NotLoggedIn
}

class AuthProvider extends ChangeNotifier{
  Status _loggedInStatus = Status.NotLoggedIn;

  Status get loggedInStatus => _loggedInStatus;

  static const loginApiEndpoint = 'http://46.41.136.84:5000/test/login';
  static const registerApiEndpoint = 'http://46.41.136.84:5000/register';

  set loggedInStatus(Status value){
    _loggedInStatus = value;
  }

  Future<bool> register(String email, String password, String userName) async {
    Response? response;
    try{
      response = await http.post(Uri.parse(registerApiEndpoint),
      headers: <String, String>{
        'Content-Type' : 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': userName,
        'password': password,
        'email' : email,
      }),
      );

    }catch (e){
      print('Error ' + e.toString());
      return false;
    }

    if(response?.statusCode == 200){
        print('Registered');
        return true;
    }
    return false;
  }  

  void login(String email, String password) async {
      Response? response;

      try{
        response = await http.post(Uri.parse(loginApiEndpoint),
        headers: <String, String>{
          'Content-Type' : 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': email,
          'password': password,
        }),
        );
      }catch(e){
        print('Error ' + e.toString());
      }
    
      if(response?.statusCode == 200){
        //Add to SharedPreferences
        final Map<String, dynamic> responseData = json.decode(response!.body);
        print(responseData);

        User authUser = User.fromJson(responseData);
        UserPreferences().saveUser(authUser);
        _loggedInStatus = Status.LoggedIn;
        notifyListeners();
      }else{
        _loggedInStatus = Status.NotLoggedIn;
        notifyListeners();
      }

  }

}