class Group {
  int id;
  String name;
  bool private;
  String base64Img;

  Group({this.id=0, this.name='', this.private = false, this.base64Img=''});

  factory Group.fromJson(Map<String, dynamic> responseData){
    return Group(
      id: responseData['id'],
      name: responseData['name'],
      private: responseData['private'],
      base64Img: responseData['img']
    );
  }
}