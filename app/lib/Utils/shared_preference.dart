import 'package:app/Models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {

  void saveUser(User user) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', user.userName);
    prefs.setString('email', user.email);
  }

}