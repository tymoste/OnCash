import 'package:flutter/material.dart'; 
import 'package:form_field_validator/form_field_validator.dart'; 
import 'package:app/Providers/auth_provider.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget { 
  const Register({Key? key}) : super(key: key); 
  
  @override 
  State<Register> createState() => _RegisterState(); 
} 
  
class _RegisterState extends State<Register> { 
  final _formkey = GlobalKey<FormState>(); 
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordrepeatController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  Map<String, String> userData = {};

  @override 
  Widget build(BuildContext context) { 
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold( 
      appBar: AppBar( 
        title: Text('Register'), 
        centerTitle: true,
        // automaticallyImplyLeading: false,
      ), 
      body: SingleChildScrollView( 
        child: Column( 
          children: <Widget>[ 
            Padding( 
              padding: const EdgeInsets.only(top: 30.0), 
              child: Center( 
                child: Container( 
                  width: 200, 
                  height: 200,  
                  child: Image.asset('lib/assets/logo.png', fit: BoxFit.fill,), 
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
                                  controller: _nameController,
                                  validator: MultiValidator([ 
                                    RequiredValidator( 
                                        errorText: 'Enter nickname'), 
                                  ]).call, 
                                  decoration: const InputDecoration( 
                                      hintText: 'Nickname', 
                                      labelText: 'Nickname', 
                                      prefixIcon: Icon( 
                                        Icons.person, 
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
                                        'Password must be atlist 8 digits'), 
                                PatternValidator(r'(?=.*?[#!@$%^&*-])', 
                                    errorText: 
                                        'Password must contain atlist one special character') 
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
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextFormField(
                              controller: _passwordrepeatController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm Password';
                                } else if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                hintText: 'Confirm Password',
                                labelText: 'Confirm Password',
                                prefixIcon: Icon(
                                  Icons.key,
                                  color: Colors.green,
                                ),
                                errorStyle: TextStyle(fontSize: 18.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.all(Radius.circular(9.0)),
                                ),
                              ),
                              obscureText: true,
                            ),
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
                                  var res;
                                  if (_formkey.currentState!.validate()) {  
                                  var res = await authProvider.register(_emailController.text, _passwordController.text,_nameController.text);
                                  if(res == true)
                                  Navigator.pushReplacementNamed(context, '/login');
                                  }
                                  else {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Registration Failed"),
                                          content: Text("Register Failed !!!"),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("OK"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                child: const Text( 
                                  'Register', 
                                  style: TextStyle( 
                                      color: Colors.white, fontSize: 22), 
                                ),   
                              ), 
                            ), 
                          ), 
                        ]), 
                  )), 
            ), 
          ], 
        ), 
      ), 
    ); 
  } 
} 