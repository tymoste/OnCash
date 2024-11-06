class User{
  String userName;
  String email;

  User({this.userName='', this.email=''});

  factory User.fromJson(Map<String, dynamic> responseData){
    return User(
      userName: responseData['username'],
      email: responseData['email'],
    );
  }

}