import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart'; 
import 'package:form_field_validator/form_field_validator.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypt/crypt.dart';
  
class Login extends StatefulWidget { 
  const Login({Key? key}) : super(key: key); 
  
  @override 
  State<Login> createState() => _LoginState(); 
} 
  
class _LoginState extends State<Login> { 
  final _formkey = GlobalKey<FormState>(); 
   final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Map<String, String> userData = {};
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar( 
        title: Text('Login'), 
        centerTitle: true, 
      ), 
      body: SingleChildScrollView( 
        child: Column( 
          children: <Widget>[ 
            Padding( 
              padding: const EdgeInsets.only(top: 30.0), 
              child: Center( 
                child: Container( 
                  width: 120, 
                  height: 120, 
                  decoration: BoxDecoration( 
                      borderRadius: BorderRadius.circular(40), 
                      border: Border.all(color: Colors.blueGrey)), 
                  child: Image.asset('assets/logo.png'), 
                ), 
              ), 
            ), 
            Padding( 
              padding: const EdgeInsets.symmetric(horizontal: 15), 
              child: Padding( 
                  padding: const EdgeInsets.all(12.0), 
                  child: Form( 
                    key: _formkey, 
                    child: Column( 
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        children: <Widget>[ 
                          Padding( 
                              padding: const EdgeInsets.all(12.0), 
                              child: TextFormField( 
                                  controller: _emailController,
                                  validator: MultiValidator([ 
                                    RequiredValidator( 
                                        errorText: 'Enter email address'), 
                                    EmailValidator( 
                                        errorText: 
                                            'Please correct email filled'), 
                                  ]).call, 
                                  decoration: const InputDecoration( 
                                      hintText: 'Email', 
                                      labelText: 'Email', 
                                      prefixIcon: Icon( 
                                        Icons.email, 
                                        //color: Colors.green, 
                                      ), 
                                      errorStyle: TextStyle(fontSize: 18.0), 
                                      border: OutlineInputBorder( 
                                          borderSide: 
                                              BorderSide(color: Colors.red), 
                                          borderRadius: BorderRadius.all( 
                                              Radius.circular(9.0)))))), 
                          Padding( 
                            padding: const EdgeInsets.all(12.0), 
                            child: TextFormField( 
                              controller: _passwordController,
                              validator: MultiValidator([ 
                                RequiredValidator( 
                                    errorText: 'Please enter Password'), 
                                MinLengthValidator(8, 
                                    errorText: 
                                        'Password must be atlist 8 digit'), 
                                PatternValidator(r'(?=.*?[#!@$%^&*-])', 
                                    errorText: 
                                        'Password must be atlist one special character') 
                              ]).call, 
                              decoration: const InputDecoration( 
                                hintText: 'Password', 
                                labelText: 'Password', 
                                prefixIcon: Icon( 
                                  Icons.key, 
                                  color: Colors.green, 
                                ), 
                                errorStyle: TextStyle(fontSize: 18.0), 
                                border: OutlineInputBorder( 
                                    borderSide: BorderSide(color: Colors.red), 
                                    borderRadius: 
                                        BorderRadius.all(Radius.circular(9.0))), 
                              ),
                              obscureText: true, 
                            ), 
                          ), 
                          Container( 
                            margin: const EdgeInsets.fromLTRB(180, 0, 0, 0), 
                            child: const Text('Forget Password!'), 
                          ), 
                          Padding( 
                            padding: const EdgeInsets.all(28.0), 
                            child: Container( 
                              width: MediaQuery.of(context).size.width, 
                              height: 50, 
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(18.0))
                                  ),
                                ),
                                  onPressed: () async { 
                                  if (_formkey.currentState!.validate()) { 
                                    // print('form submiitted'); 
                                    setState(() {
                                    userData = {
                                      "email": _emailController.text,
                                      "password": _passwordController.text
                                    };
                                  });
                                  print(userData); 
                                  var result = await loginFunction(userData['email'] as String, userData['password'] as String);
                                  print("Login Success: $result");
                                  } 
                                },
                                child: const Text( 
                                  'Login', 
                                  style: TextStyle( 
                                      color: Colors.white, fontSize: 22), 
                                ),   
                              ), 
                            ), 
                          ), 
                          const Center( 
                            child: Padding( 
                              padding: EdgeInsets.fromLTRB(0, 30, 0, 0), 
                              child: Center( 
                                child: Text( 
                                  'Or Sign In Using!', 
                                  style: TextStyle( 
                                      fontSize: 18, color: Colors.black), 
                                ), 
                              ), 
                            ), 
                          ), 
                          Row( 
                            mainAxisAlignment: MainAxisAlignment.center, 
                            children: [ 
                              Padding( 
                                padding: EdgeInsets.fromLTRB(0, 20, 0, 0), 
                                child: Row( 
                                  children: [ 
                                    Container( 
                                        height: 40, 
                                        width: 40, 
                                        child: Image.asset( 
                                          'assets/social.jpg', 
                                          fit: BoxFit.cover, 
                                        )), 
                                    Container( 
                                      height: 70, 
                                      width: 70, 
                                      child: Image.asset( 
                                        'assets/vishal.png', 
                                        fit: BoxFit.cover, 
                                      ), 
                                    ), 
                                    Container( 
                                      height: 40, 
                                      width: 40, 
                                      child: Image.asset( 
                                        'assets/google.png', 
                                        fit: BoxFit.cover, 
                                      ), 
                                    ), 
                                  ], 
                                ), 
                              ), 
                            ], 
                          ), 
                          Center( 
                            child: Container( 
                              padding: EdgeInsets.only(top: 50), 
                              child: const Text( 
                                'SIGN UP!', 
                                style: TextStyle( 
                                  fontSize: 20, 
                                  fontWeight: FontWeight.w700, 
                                  color: Colors.lightBlue, 
                                ), 
                              ), 
                            ), 
                          ) 
                        ]), 
                  )), 
            ), 
          ], 
        ), 
      ), 
    ); 
  } 
} 

Future<bool> loginFunction(String email,String password) async{
  final response = await http.post(
    Uri.parse('http://20.215.234.92:5000/test/login'),
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