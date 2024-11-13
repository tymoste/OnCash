import 'package:app/Models/user.dart';
import 'package:app/Utils/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart'; 
import 'package:app/Providers/auth_provider.dart';
import 'package:provider/provider.dart';


class ChangeUsername extends StatefulWidget {
  const ChangeUsername({super.key});

  @override
  State<ChangeUsername> createState() => _ChangeUsernameState();
}

class _ChangeUsernameState extends State<ChangeUsername> {

  final _formkey = GlobalKey<FormState>(); 
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nameRepeatController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late Future<User> userData;

  @override
  void initState() {
    super.initState();
    userData = UserPreferences().getUser();
  }

  //Map<String, String> userData = {};
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change username'),
      ),
      body: SingleChildScrollView(
        child: Column( 
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top:30),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(12),
                  child: FutureBuilder<User>(
                    future: userData,
                    builder: (context, snapshot)  {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error loading user data'));
                      } else if (!snapshot.hasData) {
                        return Center(child: Text('No user data available'));
                      } else {
                        final user = snapshot.data!;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person, size: 24, color: Colors.grey),
                            SizedBox(width: 8),
                            Text(
                              user.userName,
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              )
            ),
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
                            controller: _nameController,
                            validator: MultiValidator([ 
                              RequiredValidator( 
                                  errorText: 'Please enter new username'
                              ),
                              MinLengthValidator(5, 
                                  errorText: 'New username must be atlist 5 digit'
                              )  
                            ]).call, 
                            decoration: const InputDecoration( 
                                hintText: 'New username', 
                                labelText: 'New username', 
                                prefixIcon: Icon( 
                                  Icons.person, 
                                ), 
                                errorStyle: TextStyle(fontSize: 18.0), 
                                border: OutlineInputBorder( 
                                    borderSide: 
                                        BorderSide(color: Colors.red), 
                                    borderRadius: BorderRadius.all( 
                                        Radius.circular(9.0)
                                    )
                                )
                            )
                        )
                      ),
                      Padding( 
                        padding: const EdgeInsets.all(12.0), 
                        child: TextFormField( 
                            controller: _nameRepeatController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm username';
                              } else if (value != _nameController.text) {
                                return 'Usernames do not match';
                              }
                              return null;
                            },
                            decoration: const InputDecoration( 
                                hintText: 'Repeat username', 
                                labelText: 'Repeat username', 
                                prefixIcon: Icon( 
                                  Icons.person, 
                                ), 
                                errorStyle: TextStyle(fontSize: 18.0), 
                                border: OutlineInputBorder( 
                                    borderSide: 
                                        BorderSide(color: Colors.red), 
                                    borderRadius: BorderRadius.all( 
                                        Radius.circular(9.0)
                                    )
                                )
                            )
                        )
                      ),
                      Padding( 
                        padding: const EdgeInsets.all(12.0), 
                        child: TextFormField( 
                          controller: _passwordController,
                          validator: MultiValidator([ 
                            RequiredValidator( 
                                errorText: 'Please enter current password'
                                )
                          ]).call, 
                          decoration: const InputDecoration( 
                              hintText: 'Password', 
                              labelText: 'Password', 
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
                                  userData.then((data) async {
                                    if(await authProvider.changeUsername(data.jwt, _nameController.text, _passwordController.text)){
                                      Navigator.pushReplacementNamed(context, '/change_username');
                                  }
                                  });
                                }
                                else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Changing username failed"),
                                        content: const Text("Changing username failed"),
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
                              'Change username', 
                              style: TextStyle( 
                                  color: Colors.white, fontSize: 22
                              ), 
                            ),   
                          ), 
                        ), 
                      ), 
                    ]
                  ), 
                ),
              ),
            ),
          ]
        ),
      ),
    );
  }
}