import 'package:app/Models/user.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier{
  User _user = User();
  User get user => _user;
  void setUser(User user){
    _user = user;
    notifyListeners();
  }
  User getUser(){
    notifyListeners();
    return _user;
  }
}