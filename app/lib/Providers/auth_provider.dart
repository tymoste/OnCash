import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:app/Models/user.dart';
import 'package:app/Utils/shared_preference.dart';
import 'package:crypt/crypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Status {
  LoggedIn,
  NotLoggedIn,
  UserExists,
  Registered,
  ServerError,
  UsernameAlreadyExists,
  PasswordAlreadyExists,
  GoogleLoggedIn,

}

class AuthProvider extends ChangeNotifier{
  Status _loggedInStatus = Status.NotLoggedIn;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile', 'openid'], serverClientId: '719312073145-do6sme7t3nbus7ld4j1ld3ksuo2ass6i.apps.googleusercontent.com'); //WEB ACCESS TOKEN WTF?

  Status get loggedInStatus => _loggedInStatus;

  set loggedInStatus(Status value){
    _loggedInStatus = value;
  }

  static const loginApiEndpoint = 'http://46.41.136.84:5000/login';
  static const registerApiEndpoint = 'http://46.41.136.84:5000/register';
  static const changeUsernameApiEndpoint = 'http://46.41.136.84:5000/change_username';
  static const changePasswordApiEndpoint = 'http://46.41.136.84:5000/change_password';
  static const googleLoginEndpoint = 'http://46.41.136.84:5000/google_test';

  Future<bool> register(String email, String password, String userName) async {
    Response? response;
    try{
      response = await http.post(Uri.parse(registerApiEndpoint),
      headers: <String, String>{
        'Content-Type' : 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': userName,
        'password': Crypt.sha256(password, rounds: 0, salt: '').toString(),
        // 'password': password,
        'email' : email,
      }),
      );

    }catch (e){
      print('Error ' + e.toString());
      return false;
    }

    if(response.statusCode == 400){
      //todo
      _loggedInStatus = Status.UserExists;
      return false;
    }

    if(response.statusCode == 200){
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
          'password': Crypt.sha256(password, rounds: 0, salt: '').toString(),
          // 'password': password,
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

  Future<void> logout() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
    notifyListeners();
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
        'password': Crypt.sha256(password, rounds: 0, salt: '').toString(),
        // 'password': password,
      }),
      );
    }catch(e){
      print('Error ' + e.toString());
      return false;
    }
  
    if(response?.statusCode == 200){
      //update to SharedPreferences

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
        'oldPassword': Crypt.sha256(oldPassword, rounds: 0, salt: '').toString(),
        // 'password': Crypt.sha256(password).toString(),
        'newPassword': Crypt.sha256(newPassword, rounds: 0, salt: '').toString(),
      }),
      );
    }catch(e){
      print('Error ' + e.toString());
      return false;
    }
  
    if(response?.statusCode == 200){
      UserPreferences().changePassword(newPassword); //WTF IS THAT? GET RID OF THAT!
      notifyListeners();
      return true;
    }else{
      notifyListeners();
      return false;
    }
  }


  //-----------------------GOOGLE LOGIN METHODS-----------------------
  Future<bool> googleLogin() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if(googleUser == null){
        //login canceled
        return false;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final String? email = googleUser.email;
      final String? name = googleUser.displayName;
      final String? idToken = googleAuth.idToken;

      // TODO: SEND DATA TO SERVER HERE!!! NOT IMPLEMENTED YET
       final response = await http.post(
        Uri.parse(googleLoginEndpoint), // Możesz potrzebować osobnego endpointu
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'token': idToken ?? '', // Token Google do weryfikacji
        }),
      );


      //Get from server if token is valid and maybe if we need another token get it into prefs not this token from Google signIn!
      if(response.statusCode == 200){
        final SharedPreferences sp = await SharedPreferences.getInstance();
        sp.setString('email', email!);
        sp.setString('username', name!);
        sp.setString("jwt", idToken!); //Change this if needed, check on server and documentation
      }

      print("Email: $email, name: $name, Token: $idToken");
      _loggedInStatus = Status.GoogleLoggedIn;
      notifyListeners();
      return true;


    } catch (error) {
      print("Error during Google login: $error");
      _loggedInStatus = Status.NotLoggedIn;
      notifyListeners();
      return false;
    }
  }

  Future<void> googleLogout() async {
    await _googleSignIn.signOut();
    _loggedInStatus = Status.NotLoggedIn;
    notifyListeners();
  }

}