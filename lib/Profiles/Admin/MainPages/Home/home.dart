import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:touristine/Profiles/Tourist/MainPages/PlanMaker/customBottomSheet.dart';

class HomePage extends StatefulWidget {
  final String token;

  const HomePage({super.key, required this.token});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<String, int> visitsByCity = {
    'Jerusalem': 20,
    'Nablus': 10,
    'Ramallah': 30,
    'Bethlehem': 50
  };

  final List<Color> barColors = [
    const Color(0xFF1E889E),
    const Color.fromARGB(255, 160, 176, 160),
    const Color.fromARGB(255, 138, 169, 168),
    const Color.fromARGB(255, 211, 211, 211),
    const Color.fromARGB(255, 125, 159, 127),
    const Color.fromARGB(255, 85, 150, 146),
    const Color.fromARGB(255, 201, 147, 142),
    const Color.fromARGB(255, 168, 164, 197),
    const Color.fromARGB(255, 181, 128, 133),
    const Color.fromARGB(255, 180, 174, 107),
    const Color.fromARGB(255, 125, 165, 188),
    const Color.fromARGB(255, 160, 144, 164),
    const Color.fromARGB(255, 147, 110, 135),
    const Color.fromARGB(255, 148, 177, 166),
    const Color.fromARGB(255, 92, 142, 152),
    const Color.fromARGB(255, 123, 163, 124),
    const Color.fromARGB(255, 143, 200, 196),
    const Color.fromARGB(255, 222, 168, 163),
    const Color.fromARGB(255, 125, 107, 119),
    const Color.fromARGB(255, 134, 134, 134),
    const Color.fromARGB(255, 161, 218, 196),
    const Color.fromARGB(255, 112, 108, 136),
    const Color.fromARGB(255, 205, 150, 156),
    const Color.fromARGB(255, 201, 192, 97),
    const Color.fromARGB(255, 140, 169, 185),
    const Color.fromARGB(255, 131, 147, 131),
    const Color.fromARGB(255, 99, 129, 128),
    const Color.fromARGB(255, 167, 151, 171),
    const Color.fromARGB(255, 186, 190, 137),
    const Color.fromARGB(255, 194, 219, 172),
  ];

  String selectedCity = 'All';
  String selectedCategory = 'By City';
  double padding = 0;

  List<String> statisticsList = [
    'Visits Count',
    'Reviews Count',
    'Complaints Count',
    'Ratings Count'
  ];

  String selectedStatisticsType = '';
  void showChoicesBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return CustomBottomSheet(itemsList: statisticsList, height: 300);
      },
    ).then((value) {
      // Handle the selected item from the bottom sheet.
      if (value != null) {
        setState(() {
          selectedStatisticsType = value;
        });
        updateChart();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double maxVisits = visitsByCity.values.reduce(max).toDouble();
    double maxPaddingThreshold = 10000;
    padding = maxVisits > 0 ? min(maxVisits * 0.1, maxPaddingThreshold) : 1.0;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0.0),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0, // Remove app bar shadow.
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            height: 755,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/Images/Profiles/Admin/mainBackground.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10, top: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: ElevatedButton(
                      onPressed: showChoicesBottomSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 231, 231, 231),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Text(
                                selectedStatisticsType.isEmpty
                                    ? 'Select Statistic Type'
                                    : selectedStatisticsType,
                                style: const TextStyle(
                                    color: Color.fromARGB(163, 0, 0, 0),
                                    fontSize: 22),
                              ),
                            ),
                            const FaIcon(
                              FontAwesomeIcons.chartSimple,
                              color: Color.fromARGB(100, 0, 0, 0),
                              size: 25,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 35.0),
                        child: DropdownButton<String>(
                          value: selectedCity,
                          icon: const Icon(
                            FontAwesomeIcons.caretDown,
                            color: Color.fromARGB(104, 0, 0, 0),
                          ),
                          items: [
                            'All',
                            'Nablus',
                            'Ramallah',
                            'Jerusalem',
                            'Bethlehem'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              selectedCity = value ?? 'All';
                              updateChart();
                            });
                          },
                        ),
                      ),
                      DropdownButton<String>(
                        value: selectedCategory,
                        icon: const Icon(
                          FontAwesomeIcons.caretDown,
                          color: Color.fromRGBO(0, 0, 0, 0.5),
                        ),
                        items: [
                          'By City',
                          'Coastal Areas',
                          'Mountains',
                          'National Parks',
                          'Major Cities',
                          'Countryside',
                          'Historical Sites',
                          'Religious Landmarks',
                          'Aquariums',
                          'Zoos',
                          'Others'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            selectedCategory = value ?? 'By City';
                            updateChart();
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 500,
                    child: visitsByCity.length > 4
                        ? Scrollbar(
                            trackVisibility: true,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: buildChart(),
                            ),
                          )
                        : buildChart(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 70),
                    child: Text(
                      selectedCategory,
                      style: const TextStyle(
                        color: Color.fromARGB(163, 0, 0, 0),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Zilla Slab Light',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildChart() {
    return Row(
      children: [
        Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(left: 5),
          child: RotatedBox(
            quarterTurns: 3,
            child: Text(
              selectedStatisticsType.isEmpty
                  ? 'Visits Count'
                  : selectedStatisticsType,
              style: const TextStyle(
                  color: Color.fromARGB(163, 0, 0, 0),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Zilla Slab Light'),
            ),
          ),
        ),
        SizedBox(
          width: visitsByCity.length <= 4
              ? 360
              : (80 * visitsByCity.length).toDouble(),
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: visitsByCity.values.reduce(max).toDouble() + padding,
                barGroups: getAllCityBarGroups(),
                titlesData: FlTitlesData(
                  leftTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 45,
                    getTitles: (value) {
                      if (value == 0) {
                        return '0';
                      } else if (value >= 1000000000) {
                        return '${(value ~/ 1000000000)}B';
                      } else if (value >= 1000000) {
                        return '${(value ~/ 1000000)}M';
                      } else if (value >= 1000) {
                        return '${(value ~/ 1000)}K';
                      }
                      return value.toInt().toString();
                    },
                  ),
                  rightTitles: SideTitles(
                    showTitles: false,
                  ),
                  bottomTitles: SideTitles(
                    showTitles: true,
                    getTitles: (value) {
                      if (value.toInt() >= 0 &&
                          value.toInt() < visitsByCity.length) {
                        return visitsByCity.keys.elementAt(value.toInt());
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
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> getAllCityBarGroups() {
    return visitsByCity.keys.map((city) {
      final int index = visitsByCity.keys.toList().indexOf(city);
      return BarChartGroupData(
        x: index,
        barsSpace: 8,
        barRods: [
          BarChartRodData(
            y: visitsByCity[city]!.toDouble(),
            colors: [barColors[index]],
            borderRadius: BorderRadius.zero,
            width: 40,
          ),
        ],
      );
    }).toList();
  }

  Future<void> updateChart() async {
    print("I have changed a selection!");
    final url = Uri.parse('https://touristine.onrender.com/get-statistics');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'StatisticType': selectedStatisticsType.isNotEmpty
              ? selectedStatisticsType
              : 'Visits Count',
          'city': selectedCity,
          'category': selectedCategory
        },
      );

      if (response.statusCode == 200) {
        // Israa, here you must handle the state of
        // the chart to be updated with the new data.
        
        // Jenan, here I want to get the information arranged like a map.
        // Keep the format as a map, but change the details based on different situations.
        // An example of the format:
        /*
                    final Map<String, int> visitsByCity = {
                      'Jerusalem': 20,
                      'Nablus': 10,
                      'Ramallah': 30,
                      'Bethlehem': 50
                    };
        */
      } else {
        // Israa, handle other possible cases.
        print('Backend request failed with status code ${response.statusCode}');
      }
    } catch (error) {
      print('Error during backend request: $error');
    }
  }
}