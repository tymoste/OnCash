import 'package:app/Models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app/Models/group.dart';
import 'dart:convert';

class UserPreferences {

  final storage = new FlutterSecureStorage();
  void saveUser(User user) async{
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setString('username', user.userName);
    // prefs.setString('email', user.email);
    // prefs.setString('jwt', user.jwt);

    await storage.write(key: 'username', value: user.userName);
    await storage.write(key: 'email', value: user.email);
    await storage.write(key: 'jwt', value: user.jwt);
  }

  Future<User> getUser() async{
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = await storage.read(key: 'email') ?? '';
    String? userName = await storage.read(key: 'username') ?? '';
    String? jwt = await storage.read(key: 'jwt') ?? '';
    return User(userName: userName, email: email, jwt: jwt);
  }

  void changeUsername(String username) async{
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    await storage.write(key: 'username', value: username);
  }

}

class GroupPreferences {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  // Save list of groups to FlutterSecureStorage
  Future<void> savePublicGroups(List<Group> groups) async {
    // Konwertuj listę obiektów Group na listę JSON-ów
    List<Map<String, dynamic>> groupsJson = groups.map((group) => {
      'id': group.id,
      'name': group.name,
      'private': group.private,
      'img': group.base64Img,
      'is_admin': group.isAdmin
    }).toList();

    // Zapisz listę jako JSON w bezpiecznej pamięci
    await storage.write(key: 'groups', value: json.encode(groupsJson));
  }

  // Save private group to FlutterSecureStorage
  Future<void> savePrivateGroup(Group privateGroup) async {
    // Konwertuj obiekt Group na JSON
    Map<String, dynamic> groupJson = {
      'id': privateGroup.id,
      'name': privateGroup.name,
      'private': privateGroup.private,
      'img': '',
      
    };

    // Zapisz obiekt jako JSON w bezpiecznej pamięci
    await storage.write(key: 'privateGroup', value: json.encode(groupJson));
  }

  // Retrieve the list of groups from FlutterSecureStorage
  Future<List<Group>> getPublicGroups() async {
    // Odczytaj dane jako ciąg JSON z bezpiecznej pamięci
    String? groupsJsonString = await storage.read(key: 'groups');

    if (groupsJsonString == null || groupsJsonString.isEmpty) {
      // Jeśli brak danych, zwracamy pustą listę
      return [];
    }

    // Dekoduj JSON na listę dynamicznych obiektów
    List<dynamic> groupsJson = json.decode(groupsJsonString);

    // Mapuj listę JSON na listę obiektów Group
    return groupsJson
        .map((groupMap) => Group.fromJson(groupMap as Map<String, dynamic>))
        .toList();
  }

  // Retrieve private group from FlutterSecureStorage
  Future<Group?> getPrivateGroup() async {
    // Odczytaj dane jako ciąg JSON z bezpiecznej pamięci
    String? privateGroupJson = await storage.read(key: 'privateGroup');

    if (privateGroupJson == null || privateGroupJson.isEmpty) {
      // Jeśli brak danych, zwracamy null
      return null;
    }

    // Dekoduj JSON na obiekt Group
    return Group.fromJson(json.decode(privateGroupJson) as Map<String, dynamic>);
  }
}
