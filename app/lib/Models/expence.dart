class Expence {
  int id;
  String name;
  int categoryId;
  String categoryName;
  double price;

  Expence({this.id=-1,this.name='',this.categoryId=-1,this.categoryName='',this.price=0});

  factory Expence.fromJson(Map<String, dynamic> responseData){
    return Expence(
      id: responseData['id'],
      name: responseData['name'],
      categoryId: responseData['category_id'],
      categoryName: responseData['category_name'],
      price: responseData['price']
    );
  }

}