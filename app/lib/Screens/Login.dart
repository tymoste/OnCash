import 'package:app/Utils/shared_preference.dart';
import 'package:flutter/material.dart'; 
import 'package:form_field_validator/form_field_validator.dart'; 
import 'package:app/Providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../Models/user.dart';
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
  User? userData2;
  
  @override
  void initState() {
    super.initState();
    loadUser();
  }

   Future<void> loadUser() async {
    userData2 = await UserPreferences().getUser();
    setState(() {});
    if(userData2!.jwt.isNotEmpty){
      Provider.of<AuthProvider>(context, listen: false).updateAll(userData2!.jwt);
      Navigator.pushReplacementNamed(context, '/');
    } 
  }

  @override 
  Widget build(BuildContext context) { 
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold( 
      appBar: AppBar( 
        title: Text('Login'), 
        centerTitle: true,
        automaticallyImplyLeading: false,
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
                                        errorText: 'Enter email address or username'), 
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
                                  var res = await authProvider.login(_emailController.text, _passwordController.text);
                                  if(res == true){
                                    Navigator.pushReplacementNamed(context, '/');
                                  }
                                  else {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Login Failed"),
                                          content: Text("Login Failed !!!"),
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
                                    GestureDetector(
                                      onTap: () async {
                                        await authProvider.googleLogin();
                                        if(authProvider.loggedInStatus == Status.GoogleLoggedIn){
                                          Navigator.pushReplacementNamed(context, '/');
                                        }
                                      },
                                      child: Container( 
                                        height: 40, 
                                        width: 40, 
                                        child: Image.asset( 
                                          'lib/assets/google.png', 
                                          fit: BoxFit.cover, 
                                        ), 
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
                              child: GestureDetector(
                                onTap: (){
                                  Navigator.pushNamed(context, '/register');
                                },
                                child: const Text( 
                                'SIGN UP!', 
                                style: TextStyle( 
                                  fontSize: 20, 
                                  fontWeight: FontWeight.w700, 
                                  color: Colors.lightBlue, 
                                ), 
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