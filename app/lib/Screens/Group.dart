import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:app/Models/otherUser.dart';
import 'package:app/Providers/auth_provider.dart';
import 'package:app/Providers/group_expences_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/user.dart';
import '../Models/expence.dart';
import '../Utils/shared_preference.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import "package:app/Models/group.dart";

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  int touchedIndex = -1;
  User? userData;
  List<Group>? groupData;
  static const routeName = '/group_spendings';
  String selectedTimePeriod = 'ALL TIME';
  Map<String, Color> allCategoryColors = {};

  @override
  void initState() {
    super.initState();
    loadUser();
    loadGroup();
  }

  Future<void> loadUser() async {
    userData = await UserPreferences().getUser();
    setState(() {});
  }

  Future<void> loadGroup() async {
    groupData = await GroupPreferences().getPublicGroups();
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
  final current_group = groupData!.firstWhere(
    (group) => group.id.toString() == group_id, orElse: () => Group()
  );

  final usersInGroupProvider = Provider.of<GroupExpencesProvider>(context, listen: false);
    usersInGroupProvider.getUsersInGroupFromServer(userData!.jwt, group_id);

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
                  _buildPieChart(group_id, selectedTimePeriod),
                  const SizedBox(height: 20),
                  _buildCategoriesList(group_id, selectedTimePeriod),
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
            children: current_group.isAdmin
             ? [
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    _showAddExpenseDialog(context, group_id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 92, 182, 255),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.attach_money, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Add Expense',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 248, 254, 255),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: Center(
                  child: IconButton(
                    onPressed: () async {
                      await _generatePdfReport(context, group_id, group_name);
                    },
                    icon: const Icon(Icons.picture_as_pdf, size: 24),
                    color: Colors.orange,
                    tooltip: 'Generate PDF Report',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    _showAddCategoryDialog(context, group_id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 90, 190, 93),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.category, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Add Category',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 238, 255, 239),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]
            : [
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {
                    _showAddExpenseDialog(context, group_id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 92, 182, 255),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.attach_money, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Add Expense',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 248, 254, 255),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () async {
                    await _generatePdfReport(context, group_id, group_name);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 10)
                  ),
                  child:
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.picture_as_pdf, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Generate PDF report',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 248, 254, 255)
                          )
                        )
                      ]
                    )
                ),
              ),
            ]
            ,
          ),
        ),
      ],
    ),
  );
}


  DateTime getStartDate(String period) {
    final now = DateTime.now();
    switch (period) {
      case '1M':
        return DateTime(now.year, now.month - 1, now.day);
      case '5M':
        return DateTime(now.year, now.month - 5, now.day);
      case '1Y':
        return DateTime(now.year - 1, now.month, now.day);
      case 'ALL TIME':
      default:
        return DateTime(1970); // Earliest possible date
    }
  }

  Widget _buildTimePeriodButton(String period) {
    final isSelected = selectedTimePeriod == period;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTimePeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(255, 92, 182, 255) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color.fromARGB(255, 92, 182, 255), width: 0.5),
        ),
        child: Text(
          period,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color.fromARGB(255, 92, 182, 255),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTimePeriodSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: SizedBox(
        width: 340,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 248, 248, 248),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimePeriodButton('1M'),
                const SizedBox(width: 5),
                _buildTimePeriodButton('5M'),
                const SizedBox(width: 5),
                _buildTimePeriodButton('1Y'),
                const SizedBox(width: 5),
                _buildTimePeriodButton('ALL TIME'),
              ],
            ),
          ),
        ),
      ),
    );
  }


Color generateHarmoniousColor(int index) {
  Random random = Random(index); // Seed with index to ensure uniqueness
  double hue = random.nextDouble() * 310;
  double saturation = 0.7 + random.nextDouble() * 0.3; // Random saturation between 0.4 and 0.7
  double lightness = 0.5 + random.nextDouble() * 0.3; // Random lightness between 0.5 and 0.8

  // Generate a harmonious color using HSL (adjustable base hue)
  return HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
}

Widget _buildPieChart(String group_id, String period) {
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

      DateTime date = getStartDate(period);

      final categories = (snapshot.data![0] as List<Map<String, dynamic>>)
          .where((category) => category['category_id'] != null && category['category_name'] != null)
          .toList();

      final expenses = (snapshot.data![1] as List<Expence>)
          .where((expense) => expense.categoryId != null && expense.price != null && expense.date.isAfter(date))
          .toList();

      if (categories.isEmpty) {
        return const Center(child: Text('No categories data available'));
      }
      if (expenses.isEmpty) {
        return const Center(child: Text('No expenses data available'));
      }

      final Map<String, double> totalExpensesByCategory = {};
      for (final category in categories) {
        final categoryId = category['category_id'].toString();
        final categoryName = category['category_name'] as String;
        final totalExpense = expenses
            .where((expense) => expense.categoryId.toString() == categoryId)
            .fold<double>(0.0, (sum, expense) => sum + expense.price);
        totalExpensesByCategory[categoryName] = totalExpense;
      }

      // Generate harmonious colors for all categories with the same base hue (e.g., blueish hue)
      allCategoryColors = {}; // Reset the map before populating it

      categories.asMap().forEach((index, category) {
        final categoryName = category['category_name'];
        final color = generateHarmoniousColor(index); // Generate harmonious color for each category
        allCategoryColors[categoryName] = color; // Assign a unique color to the category
      });

      // Filter categories for the pie chart (e.g., categories with more than 1% of the total expenses)
      final totalExpenseSum = totalExpensesByCategory.values.fold(0.0, (sum, value) => sum + value);
      final filteredCategories = totalExpensesByCategory.entries
          .where((entry) => (entry.value / totalExpenseSum) > 0.01) // Categories > 1%
          .map((entry) => entry.key)
          .toList();

      // Create a filtered list of colors for the categories used in the pie chart
      final filteredCategoryColors = filteredCategories.map((categoryName) {
        return allCategoryColors[categoryName]!; // Get color for the filtered category
      }).toList();

      // Populate PieChartSectionData using the filtered categories and colors
      final sections = filteredCategories.map((categoryName) {
        final totalExpense = totalExpensesByCategory[categoryName]!;
        final color = filteredCategoryColors[filteredCategories.indexOf(categoryName)];

        return PieChartSectionData(
          value: totalExpense,
          title: '',
          //title: '${totalExpense.toStringAsFixed(2)}\$',
          color: color,
          radius: 50.0,
        );
      }).toList();

      // Sum all expenses for all categories
      final totalAllExpenses = totalExpensesByCategory.values.fold(0.0, (sum, value) => sum + value);
      // Track the touched section index to show details
      int touchedIndex = -1;

      return Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                selectedTimePeriod,
                style: TextStyle(fontSize: 12.0, color: Color.fromARGB(255, 116, 116, 116)),
              ),
              const SizedBox(height: 5),
              const Text(
                "TOTAL EXPENSES",
                style: TextStyle(fontSize: 12.0, color: Color.fromARGB(255, 58, 58, 58)),
              ),
              const SizedBox(height: 5),
              Text(
                "\$${totalAllExpenses.toStringAsFixed(2)}", // Display the total sum of expenses
                style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              if (touchedIndex >= 0)
                Text(
                  '${filteredCategories[touchedIndex]}: \$${totalExpensesByCategory[filteredCategories[touchedIndex]]!.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold),
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
                sections: sections,
              ),
            ),
          ),
        ],
      );
    },
  );
}





 Widget _buildCategoriesList(String group_id, String period) {
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
      DateTime date = getStartDate(period);

      final Map<String, List<Expence>> expensesByCategory = {};
      for (final category in categories) {
        final categoryId = category['category_id'].toString();
        expensesByCategory[categoryId] = expenses
            .where((expense) => expense.categoryId.toString() == categoryId.toString() && expense.date.isAfter(date))
            .toList();
      }

      return SizedBox(
        height: 325, // Define height for the scrollable list
        child: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final categoryName = category['category_name'];
            final categoryExpenses = expensesByCategory[category['category_id'].toString()] ?? [];
            final provider = Provider.of<GroupExpencesProvider>(context, listen: false);
            List<otherUser> users = provider.users;
            int myId = users.firstWhere(
              (user) => user.email == userData!.email
            ).userID;
            // Calculate the total expenses for the category
            double totalCategoryExpense = categoryExpenses.fold(0.0, (sum, expense) => sum + expense.price);

            // Get the color for this category
            final categoryColor = allCategoryColors[categoryName] ?? const Color.fromARGB(255, 105, 105, 105);

            return Card(
              elevation: 2,
              child: ExpansionTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 10.0,
                      height: 10.0,
                      margin: const EdgeInsets.only(right: 8.0),
                      decoration: BoxDecoration(
                        color: categoryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        categoryName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '\$${totalCategoryExpense.toStringAsFixed(2)}', // Display total expense
                      style: const TextStyle(fontSize: 14, color: Colors.green),
                    ),
                  ],
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${expense.price}\$',
                                style: const TextStyle(color: Colors.green, fontSize: 14),
                              ),
                              if(myId == expense.adderId)
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Confirm Delete'),
                                          content: const Text('Are you sure you want to delete this expense?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                // Perform delete operation here
                                                Provider.of<GroupExpencesProvider>(context, listen: false).deleteExpenseFromGroup(userData!.jwt, expense.id); 
                                                Navigator.of(context).pop();
                                                setState(() {});
                                              },
                                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                            ],
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
                    setState(() {});
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

Future<void> _generatePdfReport(BuildContext context, String groupId, String groupName) async {
  final provider = Provider.of<GroupExpencesProvider>(context, listen: false);

  final categories = await provider.getGroupCategories(userData!.jwt, groupId);
  final expenses = await provider.getExpensesFromGroup(userData!.jwt, groupId);

  final Map<String, List<Expence>> expensesByCategory = {};
  for (final category in categories) {
    final categoryId = category['category_id'].toString();
    expensesByCategory[categoryId] = expenses
        .where((expense) => expense.categoryId.toString() == categoryId)
        .toList();
  }

  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        pw.Header(
          level: 0,
          child: pw.Text("$groupName Report", style: pw.TextStyle(fontSize: 24)),
        ),
        pw.SizedBox(height: 10),
        ...categories.map((category) {
          final categoryName = category['category_name'];
          final categoryExpenses =
              expensesByCategory[category['category_id'].toString()] ?? [];
          final totalExpense = categoryExpenses.fold(
            0.0,
            (sum, expense) => sum + expense.price,
          );

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "$categoryName (\$${totalExpense.toStringAsFixed(2)})",
                style: pw.TextStyle(
                    fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              categoryExpenses.isEmpty
                  ? pw.Text("No expenses in this category",
                      style: pw.TextStyle(fontSize: 12))
                  : pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: categoryExpenses.map((expense) {
                        return pw.Row(
                          children: [
                            pw.Text("- ",
                                style: pw.TextStyle(fontSize: 12,)), // Punkt
                            pw.Expanded(
                              child: pw.Text(
                                "${expense.name}: \$${expense.price.toStringAsFixed(2)}",
                                style: pw.TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
              pw.SizedBox(height: 10),
            ],
          );
        }).toList(),
      ],
    ),
  );

  try {
    final output = await getTemporaryDirectory();
    final filePath = "${output.path}/group_report.pdf";
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    await OpenFilex.open(filePath);
  } catch (e) {
    print("Error while saving/opening PDF: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to generate or open PDF")),
    );
  }
}

  void _showAddCategoryDialog(BuildContext context, String groupId) {
    final _formKey = GlobalKey<FormState>();
    final _categoryNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Category"),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _categoryNameController,
              decoration: const InputDecoration(labelText: "Category Name"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a category name';
                }
                return null;
              },
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
                  String categoryName = _categoryNameController.text;

                  final groupExpensesProvider =
                      Provider.of<GroupExpencesProvider>(context, listen: false);
                  groupExpensesProvider.addNewGroupCategory(userData!.jwt, groupId, categoryName).then((isSuccess) {
                    if (isSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Category added successfully')),
                      );
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to add category')),
                      );
                    }
                  });
                }
              },
              child: const Text('Add Category'),
            ),
          ],
        );
      },
    );
  }

}



