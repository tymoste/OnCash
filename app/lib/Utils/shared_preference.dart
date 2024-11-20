import 'package:app/Models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  //????? WHAT IS THAT ?????
  //WE CANNOT STORE THE PASSWORD
  void changePassword(String newPassword) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('password', newPassword);
  }

}