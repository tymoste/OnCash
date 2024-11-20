class User{
  String userName;
  String email;
  String jwt;

  User({this.userName='', this.email='', this.jwt = ""});

  factory User.fromJson(Map<String, dynamic> responseData){
    return User(
      userName: responseData['username'],
      email: responseData['email'],
      jwt: responseData['jwt']
    );
  }

  String getJwt(){
    return jwt;
  }

}