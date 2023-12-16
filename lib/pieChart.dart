import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Pie Chart Example'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  color: Colors.blue,
                  value: 40,
                  title: '40%',
                  radius: 80,
                  titleStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xffffffff),
                  ),
                ),
                PieChartSectionData(
                  color: Colors.green,
                  value: 30,
                  title: '30%',
                  radius: 80,
                  titleStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xffffffff),
                  ),
                ),
                PieChartSectionData(
                  color: Colors.orange,
                  value: 20,
                  title: '20%',
                  radius: 80,
                  titleStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xffffffff),
                  ),
                ),
                PieChartSectionData(
                  color: Colors.red,
                  value: 10,
                  title: '10%',
                  radius: 80,
                  titleStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xffffffff),
                  ),
                ),
              ],
              centerSpaceRadius: 40,
            ),
          ),
        ),
      ),
    );
  }
}
