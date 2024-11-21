import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart'; 

class GroupSpendingsScreenArguments {
  final String group_id;
  final String group_name;

  GroupSpendingsScreenArguments(this.group_id, this.group_name);
}

class Group extends StatefulWidget { 
  //final int group_id;

  const Group({Key? key}) : super(key: key);
  
  //required this.group_id
  //Group({required this.group_id})

  @override 
  State<Group> createState() => _GroupState(); 
}

class _GroupState extends State<Group>{
  int touchedIndex = -1;
  static const routeName = '/group_spendings';
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments; //as GroupSpendingsScreenArguments;
  
    return Scaffold(
      appBar: AppBar(
        title: Text(args.toString()), //widget.group_id as String
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Center(
            child: Column(
              children: <Widget>[ 
                Padding( 
                  padding: const EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 5.0,
                  ),
                  child: SizedBox( 
                    width: 300, //MediaQuery.of(context).size.width,
                    height: 60, 
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 241, 241, 241),
                          borderRadius: BorderRadius.circular(20),
                        ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 60,
                                height: 20,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(18.0))
                                    ),
                                  ),
                                    
                                  onPressed: () {  },
                                  child: const Text( 
                                    '1M', 
                                    style: TextStyle( 
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 54, 54, 54), fontSize: 8
                                    ), 
                                  )   
                                ),
                              ),
                              const SizedBox(width: 3),
                              SizedBox(
                                width: 60,
                                height: 20,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(18.0))
                                    ),
                                  ),
                                    
                                  onPressed: () {  },
                                  child: const Text( 
                                    '5M', 
                                    style: TextStyle( 
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 54, 54, 54), fontSize: 8
                                    ), 
                                  )   
                                ),
                              ),
                              const SizedBox(width: 3),
                              SizedBox(
                                width: 60,
                                height: 20,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(18.0))
                                    ),
                                  ),
                                  onPressed: () {  },
                                  child: const Text( 
                                    '1Y', 
                                    style: TextStyle( 
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 54, 54, 54), fontSize: 8
                                    ), 
                                  )   
                                ),
                              ),
                              const SizedBox(width: 3),
                              SizedBox(
                                width: 70,
                                height: 20,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(18.0))
                                    ),
                                  ),
                                    
                                  onPressed: () {  },
                                  child: const Text( 
                                    'ALL TIME', 
                                    style: TextStyle( 
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 54, 54, 54), fontSize: 7
                                    ), 
                                  )   
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    )
                ),
                 
               

                Padding( 
                  padding: const EdgeInsets.only(top: 10.0), //all(10.0), 
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "ALL TIME",
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal,
                              color: Color.fromARGB(255, 116, 116, 116),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "TOTAL EXPENSES",
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal,
                              color: Color.fromARGB(255, 58, 58, 58),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "3000\$",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 31, 31, 31),
                            ),
                          ),
                        ]
                      ),
                      
                      SizedBox(
                        width: 300.0,
                        height: 300.0,
                        child: PieChart(
                          
                          swapAnimationDuration: const Duration(milliseconds: 750),
                          swapAnimationCurve: Curves.easeInOutQuint,
                          
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
                                  touchedIndex = pieTouchResponse
                                      .touchedSection!.touchedSectionIndex;
                                  });
                              },
                            ),
                            
                            sectionsSpace: 12,
                            startDegreeOffset: 180,
                            titleSunbeamLayout: true,
                            sections: showingSections(), 
                            // [
                            //   PieChartSectionData( 
                            //     value: 1,
                            //     color: Colors.blueAccent,
                            //   ),
                            //   PieChartSectionData(
                            //     value: 2,
                            //     color: Colors.amberAccent,
                            //   ),
                            //   PieChartSectionData(
                            //     value: 5,
                            //     color: Colors.cyanAccent,
                            //   )
                            // ]
                          ),
                        ),
                      )
                    ],
                  )
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: 5,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: const Icon(Icons.list),
                      trailing: const Text(
                        "35\$",
                        style: TextStyle(color: Colors.green, fontSize: 15),
                      ),
                      title: Text("Category $index")
                    );
                  }
                )

              ]
            )
          )  
        )
      )
    );
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
}