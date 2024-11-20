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
        title: Text('Group'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Center(

            child: Stack(
              alignment: Alignment.center,


              children: [
                const Text("3000\$"),

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
          )  
        )
      ),
    );
  }
}