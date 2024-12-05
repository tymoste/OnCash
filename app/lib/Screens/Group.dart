import 'dart:convert';
import 'package:app/Providers/auth_provider.dart';
import 'package:app/Providers/group_expences_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/user.dart';
import '../Models/expence.dart';
import '../Utils/shared_preference.dart';

class GroupSpendingsScreenArguments {
  final String group_id;
  final String group_name;

  GroupSpendingsScreenArguments(this.group_id, this.group_name);
}

class Group extends StatefulWidget {
  const Group({super.key});

  @override
  State<Group> createState() => _GroupState();
}

class _GroupState extends State<Group> {
  int touchedIndex = -1;
  User? userData;
  static const routeName = '/group_spendings';

  @override
  void initState() {
    super.initState();
    loadUser();
  }

   Future<void> loadUser() async {
    userData = await UserPreferences().getUser();
    setState(() {});
  }

 @override
Widget build(BuildContext context) {
  var args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
  if (args == null) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Screen')),
      body: const Center(
        child: Text('No arguments passed'),
      ),
    );
  }

  String group_id = args['group_id'].toString();
  String group_name = args['group_name'].toString();

  return Scaffold(
    appBar: AppBar(
      title: Text(group_name),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.group),
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/get_users_in_group',
              arguments: {
                "group_id": group_id,
                "group_name": group_name,
              },
            );
          },
        ),
      ],
    ),
    body: Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 10),
                  _buildTimePeriodSelector(),
                  const SizedBox(height: 20),
                  _buildPieChart(),
                  const SizedBox(height: 20),
                  _buildCategoriesList(group_id),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _showAddExpenseDialog(context, group_id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.attach_money, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Add Expense',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Add your second button logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.category, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'View Categories',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildTimePeriodSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: SizedBox(
        width: 300,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 241, 241, 241),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimePeriodButton('1M'),
                const SizedBox(width: 3),
                _buildTimePeriodButton('5M'),
                const SizedBox(width: 3),
                _buildTimePeriodButton('1Y'),
                const SizedBox(width: 3),
                _buildTimePeriodButton('ALL TIME'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimePeriodButton(String label) {
    return SizedBox(
      width: 60,
      height: 20,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18.0)),
          ),
        ),
        onPressed: () {},
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 54, 54, 54),
            fontSize: 8,
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "ALL TIME",
              style: TextStyle(fontSize: 12.0, color: Color.fromARGB(255, 116, 116, 116)),
            ),
            SizedBox(height: 5),
            Text(
              "TOTAL EXPENSES",
              style: TextStyle(fontSize: 12.0, color: Color.fromARGB(255, 58, 58, 58)),
            ),
            SizedBox(height: 5),
            Text(
              "3000\$",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(
          width: 300.0,
          height: 300.0,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sectionsSpace: 12,
              startDegreeOffset: 180,
              sections: showingSections(),
            ),
          ),
        ),
      ],
    );
  }

 Widget _buildCategoriesList(String group_id) {
  return FutureBuilder(
    future: Future.wait([
      _fetchGroupCategories(group_id),
      _fetchGroupExpenses(group_id),
    ]),
    builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(child: Text('No data available'));
      }

      final categories = snapshot.data![0] as List<Map<String, dynamic>>;
      final expenses = snapshot.data![1] as List<Expence>;

      final Map<String, List<Expence>> expensesByCategory = {};
      for (final category in categories) {
        final categoryId = category['category_id'].toString();
        expensesByCategory[categoryId] = expenses
            .where((expense) => expense.categoryId.toString() == categoryId.toString())
            .toList();
      }

      return SizedBox(
        height: 325, // Define height for the scrollable list
        child: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final categoryExpenses = expensesByCategory[category['category_id'].toString()] ?? [];

            return Card(
              elevation: 2,
              child: ExpansionTile(
                title: Text(
                  category['category_name'],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                children: categoryExpenses.isEmpty
                    ? [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('No expenses in this category'),
                        ),
                      ]
                    : categoryExpenses.map((expense) {
                        return ListTile(
                          title: Text(expense.name),
                          trailing: Text(
                            '${expense.price}\$',
                            style: const TextStyle(color: Colors.green, fontSize: 14),
                          ),
                        );
                      }).toList(),
              ),
            );
          },
        ),
      );
    },
  );
}


  Future<List<Map<String, dynamic>>> _fetchGroupCategories(String groupId) async {
    final provider = Provider.of<GroupExpencesProvider>(context, listen: false);
    var res = await provider.getGroupCategories(userData!.jwt, groupId);
    return res;
  }

  Future<List<Expence>> _fetchGroupExpenses(String groupId) async {
    final provider = Provider.of<GroupExpencesProvider>(context, listen: false);
     var res = await provider.getExpensesFromGroup(userData!.jwt, groupId);
    return res;
  }

  List<PieChartSectionData> showingSections() {
      return List.generate(4, (i) {
        final isTouched = i == touchedIndex;
        final fontSize = isTouched ? 20.0 : 13.0;
        final radius = isTouched ? 40.0 : 30.0;
        //const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
        switch (i) {
          case 0:
            return PieChartSectionData(
              color: Colors.green,
              value: 40,
              //title: '40%',
              radius: radius,
              showTitle: false,
              titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 44, 44, 44),
                //shadows: shadows,
              ),
            );
          case 1:
            return PieChartSectionData(
              color: Colors.yellow,
              value: 30,
              //title: '30%',
              radius: radius,
              showTitle: false,
              titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 44, 44, 44),
                //shadows: shadows,
              ),
            );
          case 2:
            return PieChartSectionData(
              color: Colors.purple,
              value: 15,
              //title: '15%',
              radius: radius,
              showTitle: false,
              titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 44, 44, 44),
                //shadows: shadows,
              ),
            );
          case 3:
            return PieChartSectionData(
              color: Colors.blue,
              value: 15,
              //title: '15%',
              radius: radius,
              showTitle: false,
              titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 44, 44, 44),
                //shadows: shadows,
              ),
            );
          default:
            throw Error();
        }
      });
  }

void _showAddExpenseDialog(BuildContext context, String groupId) {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? selectedCategory;
  String? selectedCategoryName;
  List<Map<String, dynamic>>? categories;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Add Expense"),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Expense Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Price"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              FutureBuilder(
                future: _fetchGroupCategories(groupId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No categories available');
                  }

                  categories = snapshot.data as List<Map<String, dynamic>>;

                  return Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        hint: const Text("Select Category"),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCategory = newValue;
                            selectedCategoryName = categories
                                ?.firstWhere((category) => category['category_id'].toString() == newValue)['category_name'];
                          });
                        },
                        items: categories?.map<DropdownMenuItem<String>>((category) {
                          return DropdownMenuItem<String>(
                            value: category['category_id'].toString(),
                            child: Text(category['category_name']),
                          );
                        }).toList(),
                        menuMaxHeight: 200,
                      ),
                      if (selectedCategory != null && selectedCategoryName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            "Selected Category: $selectedCategoryName",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                double price = double.parse(_priceController.text);
                String name = _nameController.text;
                String description = _descriptionController.text;
                String categoryId = selectedCategory ?? '';
                
                final groupExpensesProvider = Provider.of<GroupExpencesProvider>(context, listen: false);
                groupExpensesProvider.addExpenseToGroup(
                  userData!.jwt,
                  groupId,
                  categoryId,
                  price,
                  description,
                  name,
                ).then((isSuccess) {
                  if (isSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Expense added successfully')),
                    );
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to add expense')),
                    );
                  }
                });
              }
            },
            child: const Text('Add Expense'),
          ),
        ],
      );
    },
  );
}



}



