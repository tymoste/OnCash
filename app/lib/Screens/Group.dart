import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart'; 

class Group extends StatefulWidget { 
  const Group({Key? key}) : super(key: key); 
  
  @override 
  State<Group> createState() => _GroupState(); 
}


class _GroupState extends State<Group>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Name'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Center(
            child: Column(
              children: <Widget>[ 
                Padding( 
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 5.0,
                  ),
                  child: SizedBox( 
                    //width: MediaQuery.of(context).size.width,
                    //height: 40, 
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[300], // Szary kolor tła
                          borderRadius: BorderRadius.circular(20), // Zaokrąglenie rogów
                        ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 80,
                                height: 30,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 213, 214, 214),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(18.0))
                                    ),
                                  ),
                                    
                                  onPressed: () {  },
                                  child: const Text( 
                                    '1M', 
                                    style: TextStyle( 
                                        color: Colors.white, fontSize: 12
                                    ), 
                                  )   
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 80,
                                height: 30,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 213, 214, 214),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(18.0))
                                    ),
                                  ),
                                    
                                  onPressed: () {  },
                                  child: const Text( 
                                    '5M', 
                                    style: TextStyle( 
                                        color: Colors.white, fontSize: 12
                                    ), 
                                  )   
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 80,
                                height: 30,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 213, 214, 214),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(18.0))
                                    ),
                                  ),
                                  onPressed: () {  },
                                  child: const Text( 
                                    '1Y', 
                                    style: TextStyle( 
                                        color: Colors.white, fontSize: 12
                                    ), 
                                  )   
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 80,
                                height: 30,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 213, 214, 214),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(18.0))
                                    ),
                                  ),
                                    
                                  onPressed: () {  },
                                  child: const Text( 
                                    'ALL TIME', 
                                    style: TextStyle( 
                                        color: Colors.white, fontSize: 12
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
                        width: 200.0,
                        height: 300.0,
                        child: PieChart(
                          //
                          swapAnimationDuration: const Duration(milliseconds: 750),
                          swapAnimationCurve: Curves.easeInOutQuint,
                          PieChartData(
                            sections: [
                              PieChartSectionData( 
                                value: 1,
                                color: Colors.blueAccent,
                              ),
                              PieChartSectionData(
                                value: 2,
                                color: Colors.amberAccent,
                              ),
                              PieChartSectionData(
                                value: 5,
                                color: Colors.cyanAccent,
                              )
                            ]
                          ),
                        ),
                      )
                    ],
                  )
                ),
              ]
            )
          )  
        )
      )
    );
  }
}