import 'package:app/Models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {

  void saveUser(User user) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', user.userName);
    prefs.setString('email', user.email);
  }

  Future<User> getUser() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email') ?? '';
    String? userName = prefs.getString('username') ?? '';
    return User(userName: userName, email: email);
  }

}