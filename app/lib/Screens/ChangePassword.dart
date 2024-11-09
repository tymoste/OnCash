import 'package:app/Providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart'; 
import 'package:app/Providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {

  final _formkey = GlobalKey<FormState>(); 
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _newpasswordRepeatController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  Map<String, String> userData = {};

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change password'),
      ),
      body: SingleChildScrollView(
        child: Column( 
          children: <Widget>[ 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child:Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: _formkey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding( 
                        padding: const EdgeInsets.all(12.0), 
                        child: TextFormField( 
                          controller: _newPasswordController,
                          validator: MultiValidator([ 
                            RequiredValidator( 
                              errorText: 'Please enter Password'
                            ), 
                            MinLengthValidator(8, 
                              errorText: 'Password must be atlist 8 digit'
                            ), 
                            PatternValidator(r'(?=.*?[#!@$%^&*-])', 
                              errorText: 'Password must be atlist one special character'
                            ) 
                          ]).call, 
                          decoration: const InputDecoration( 
                              hintText: 'New password', 
                              labelText: 'New password', 
                              prefixIcon: Icon( 
                                Icons.key, 
                              ), 
                              errorStyle: TextStyle(fontSize: 18.0), 
                              border: OutlineInputBorder( 
                                  borderSide: 
                                      BorderSide(color: Colors.red), 
                                  borderRadius: BorderRadius.all( 
                                      Radius.circular(9.0)
                                  )
                              )
                          ),
                          obscureText: true
                        )
                      ),
                      Padding( 
                        padding: const EdgeInsets.all(12.0), 
                        child: TextFormField( 
                          controller: _newpasswordRepeatController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm Password';
                            } else if (value != _newPasswordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          decoration: const InputDecoration( 
                              hintText: 'Repeat password', 
                              labelText: 'Repeat password', 
                              prefixIcon: Icon( 
                                Icons.key, 
                              ), 
                              errorStyle: TextStyle(fontSize: 18.0), 
                              border: OutlineInputBorder( 
                                  borderSide: 
                                      BorderSide(color: Colors.red), 
                                  borderRadius: BorderRadius.all( 
                                      Radius.circular(9.0)
                                  )
                              )
                          ),
                          obscureText: true
                        )
                      ),
                      Padding( 
                        padding: const EdgeInsets.all(12.0), 
                        child: TextFormField( 
                          controller: _currentPasswordController,
                          validator: MultiValidator([ 
                            RequiredValidator( 
                                errorText: 'Please enter current password'
                                )
                          ]).call, 
                          decoration: const InputDecoration( 
                              hintText: 'Current Password', 
                              labelText: 'Current Password', 
                              prefixIcon: Icon( 
                                Icons.key,
                              ), 
                              errorStyle: TextStyle(fontSize: 18.0), 
                              border: OutlineInputBorder( 
                                  borderSide: 
                                      BorderSide(color: Colors.red), 
                                  borderRadius: BorderRadius.all( 
                                      Radius.circular(9.0)
                                  )
                              )
                          ),
                          obscureText: true
                        )
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
                                  // tu nie jestem pewien czy to powinno byc UserProvider().user.userName
                                  var res = await authProvider.changeUsername(UserProvider().user.userName, _newPasswordController.text);
                                  if(res == true){
                                    Navigator.pushReplacementNamed(context, '/change_password');
                                  }
                                }
                                else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Changing password Failed"),
                                        content: const Text("Changing password Failed"),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("OK"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                            },
                            child: const Text( 
                              'Change password', 
                              style: TextStyle( 
                                  color: Colors.white, fontSize: 22
                              ), 
                            ),   
                          ), 
                        ), 
                      ),
                    ]
                  )
                ) 
              )
            )
          ],
        ), 
      ),
    );
  }
}