class User{
  String userName;
  String email;
  String jwt;


  User({this.userName='', this.email='', this.jwt = ""});

  factory User.fromJson(Map<String, dynamic> responseData){

    // if(responseData['jwt'] == Null){
    //   print("\n\n\n\n\njwt is null\n\n\n\n\n\n");
    //   return User(
    //     userName: responseData['username'],
    //     email: responseData['email'],
    //     jwt: "",
    //   );
    // } else {
    return User(
      userName: responseData['username'],
      email: responseData['email'],
      jwt: responseData['jwt']
    );
    // }


  }

  String getJwt(){
    return jwt;
  }

}