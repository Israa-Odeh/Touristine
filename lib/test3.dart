import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // List of integers representing the number of visits for each city
  final List<int> numOfVisits = [20, 80, 50, 60];
  final List<int> numOfViews = [30, 60, 40, 80];
  final List<int> numOfLikes = [15, 45, 25, 30];
  final List<int> numOfShares = [10, 30, 20, 40];
  final List<Color> barColors = [
    const Color(0xFF1E889E),
    const Color.fromARGB(83, 37, 87, 39),
    const Color.fromARGB(108, 14, 144, 137),
    const Color.fromARGB(89, 102, 29, 23),
  ];
  final List<String> categories = ['Category1', 'Category2', 'Category3', 'Category4'];
  final List<String> cityNames = ['Jerusalem', 'Nablus', 'Ramallah', 'Bethlehem'];

  @override
  Widget build(BuildContext context) {
    // Calculate the maximum value across all categories
    double maxVisits = max(
      max(numOfVisits[0].toDouble(), max(numOfVisits[1].toDouble(), max(numOfVisits[2].toDouble(), numOfVisits[3].toDouble()))),
      max(numOfViews[0].toDouble(), max(numOfViews[1].toDouble(), max(numOfViews[2].toDouble(), numOfViews[3].toDouble()))),
    );

    double maxPaddingThreshold = 1000;
    double padding = maxVisits > 0 ? min(maxVisits * 0.1, maxPaddingThreshold) : 1.0;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('City Visits Chart'),
        ),
        body: Column(
          children: [
            Container(
              height: 500,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxVisits + padding, // Add some padding to the maxY value
                    barGroups: List.generate(
                      categories.length,
                      (categoryIndex) => BarChartGroupData(
                        x: categoryIndex,
                        barsSpace: 3,
                        barRods: [
                          BarChartRodData(
                            y: numOfVisits[categoryIndex].toDouble(),
                            colors: [barColors[0]],
                            borderRadius: BorderRadius.zero,
                            width: 10,
                          ),
                          BarChartRodData(
                            y: numOfViews[categoryIndex].toDouble(),
                            colors: [barColors[1]],
                            borderRadius: BorderRadius.zero,
                            width: 10,
                          ),
                          BarChartRodData(
                            y: numOfLikes[categoryIndex].toDouble(),
                            colors: [barColors[2]],
                            borderRadius: BorderRadius.zero,
                            width: 10,
                          ),
                          BarChartRodData(
                            y: numOfShares[categoryIndex].toDouble(),
                            colors: [barColors[3]],
                            borderRadius: BorderRadius.zero,
                            width: 10,
                          ),
                        ],
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: SideTitles(showTitles: true, reservedSize: 30),
                      rightTitles: SideTitles(showTitles: false),
                      bottomTitles: SideTitles(
                        showTitles: true,
                        getTitles: (value) {
                          if (value.toInt() >= 0 && value.toInt() < categories.length) {
                            return categories[value.toInt()];
                          }
                          return '';
                        },
                      ),
                      topTitles: SideTitles(showTitles: false),
                    ),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: const Color(0xff37434d), width: 1),
                    ),
                  ),
                ),
              ),
            ),

         Column(
           children: [
             Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    cityNames.length - 2,
                    (index) => Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        width: 100,
                        height: 30,
                        color: barColors[index],
                        child: Center(
                          child: Text(
                            cityNames[index],
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 0),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    cityNames.length - 2,
                    (index) => Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        width: 100,
                        height: 30,
                        color: barColors[index + 2],
                        child: Center(
                          child: Text(
                            cityNames[index + 2],
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
           ],
         ),
          ],
        ),
      ),
    );
  }
}