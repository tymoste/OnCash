import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypt/crypt.dart';

Future<bool> loginFunction(String email,String password) async{
  final response = await http.post(
    Uri.parse('http://46.41.136.84:5000/test/login'),
    headers: <String,String>{
      'Content-Type' : 'application/json; charset=UTF-8'
    },
    body: jsonEncode(<String,String>{
      'username' : email,
      'password' : Crypt.sha256(password).toString(),
    })
  );
  if(response.statusCode == 200){
    return true;
  }
  else{
    return false;
  }
}