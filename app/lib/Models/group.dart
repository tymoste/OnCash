class Group {
  int id;
  String name;
  bool private;

  Group({this.id=0, this.name='', this.private = false});

  factory Group.fromJson(Map<String, dynamic> responseData){
    return Group(
      id: responseData['id'],
      name: responseData['name'],
      private: responseData['private']
    );
  }
}