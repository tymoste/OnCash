class otherUser{
  String userName;
  int userID;
  String email;

  otherUser({this.email='', this.userID=0, this.userName=''});

// todo: add group_roles, add personal_img
  factory otherUser.fromJson(Map<String, dynamic> responseData){
    return otherUser(
      email: responseData['email'],
      userID: responseData['user_id'],
      userName: responseData['username'],
    );
  }
}