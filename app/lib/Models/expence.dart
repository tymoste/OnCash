import 'package:intl/intl.dart';

class Expence {
  int id;
  String name;
  int categoryId;
  String categoryName;
  double price;
  DateTime date;

  Expence({this.id=-1,this.name='',this.categoryId=-1,this.categoryName='',this.price=0, required this.date});

  factory Expence.fromJson(Map<String, dynamic> responseData){
    return Expence(
      id: responseData['id'],
      name: responseData['name'],
      categoryId: responseData['category_id'],
      categoryName: responseData['category_name'],
      price: responseData['price'],
      date: DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parse(responseData['date'])
    );
  }

} 