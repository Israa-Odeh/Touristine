import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:touristine/Notifications/SnackBar.dart';
import 'package:touristine/Profiles/Tourist/MainPages/planMaker/customBottomSheet.dart';

class HomePage extends StatefulWidget {
  final String token;

  const HomePage({Key? key, required this.token}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double reservedSizeForBottomTitles = 30;
  int maxNumberOfWords = 0;

  final Map<String, int> statisticsResult = {
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
    const Color.fromARGB(255, 177, 207, 179),
    const Color.fromARGB(255, 113, 163, 159),
    const Color.fromARGB(255, 154, 192, 206),
    const Color.fromARGB(255, 140, 187, 174),
    const Color.fromARGB(255, 172, 172, 172),
    const Color.fromARGB(255, 203, 201, 175),
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
  String selectedCategory = '';
  double padding = 0;

  List<String> statisticsList = [
    'Visits Count',
    'Reviews Count',
    'Complaints Count',
    'Ratings Count'
  ];

  String selectedStatisticsType = '';
  ChartType selectedChartType = ChartType.bar;

  void showChoicesBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return CustomBottomSheet(itemsList: statisticsList, height: 300);
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          selectedStatisticsType = value;
        });
      }
    });
  }

  List<String> getCategoriesListForAllChoice() {
    return [
      'By City',
      'By Category',
      'Coastal Areas',
      'Mountains',
      'National Parks',
      'Major Cities',
      'Countryside',
      'Historical Sites',
      'Religious Landmarks',
      'Aquariums',
      'Zoos',
      'Others',
    ];
  }

  List<String> getCategoriesListForNonAll() {
    return [
      'By Category',
      'Coastal Areas',
      'Mountains',
      'National Parks',
      'Major Cities',
      'Countryside',
      'Historical Sites',
      'Religious Landmarks',
      'Aquariums',
      'Zoos',
      'Others',
    ];
  }

  double calculateReservedSize(int maxNumberOfWords) {
    return maxNumberOfWords == 1
        ? 15
        : maxNumberOfWords == 2
            ? 30
            : maxNumberOfWords == 3
                ? 48
                : maxNumberOfWords == 4
                    ? 65
                    : 82;
  }

  @override
  Widget build(BuildContext context) {
    if (selectedCity == 'All') {
      selectedCategory = getCategoriesListForAllChoice().first;
    } else {
      selectedCategory = getCategoriesListForNonAll().first;
    }
    double maxVisits = statisticsResult.values.reduce(max).toDouble();
    double maxPaddingThreshold = 100000;
    padding = maxVisits > 0 ? min(maxVisits * 0.1, maxPaddingThreshold) : 1.0;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0.0),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
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
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: selectedChartType == ChartType.bar
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.spaceAround,
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
                        items: (selectedCity == 'All'
                                ? getCategoriesListForAllChoice()
                                : getCategoriesListForNonAll())
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              selectedCategory = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: selectedChartType == ChartType.bar ? 450 : 490,
                    child: statisticsResult.length > 4 &&
                            selectedChartType == ChartType.bar
                        ? Scrollbar(
                            trackVisibility: true,
                            // thumbVisibility: true,
                            child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: buildBarChart()),
                          )
                        : selectedChartType == ChartType.bar
                            ? buildBarChart()
                            : buildPieChart(),
                  ),
                  if (selectedChartType == ChartType.bar)
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
                  SizedBox(
                      height: selectedChartType == ChartType.bar ? 30 : 36),
                  if (statisticsResult.length <= 10)
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildCircularIconButton(
                            icon: FontAwesomeIcons.chartColumn,
                            onPressed: () {
                              setState(() {
                                selectedChartType = ChartType.bar;
                              });
                              if (selectedStatisticsType.isNotEmpty &&
                                  selectedCity.isNotEmpty &&
                                  selectedCategory.isNotEmpty) {
                                updateChart();
                              } else {
                                showCustomSnackBar(context,
                                    'Please select the relevant options',
                                    bottomMargin: 0);
                              }
                            },
                          ),
                          _buildCircularIconButton(
                            icon: FontAwesomeIcons.chartPie,
                            onPressed: () {
                              setState(() {
                                selectedChartType = ChartType.pie;
                              });
                              if (selectedStatisticsType.isNotEmpty &&
                                  selectedCity.isNotEmpty &&
                                  selectedCategory.isNotEmpty) {
                                updateChart();
                              } else {
                                showCustomSnackBar(context,
                                    'Please select the relevant options',
                                    bottomMargin: 0);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  if (statisticsResult.length > 10)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 70.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedStatisticsType.isNotEmpty &&
                              selectedCity.isNotEmpty &&
                              selectedCategory.isNotEmpty) {
                            updateChart();
                          } else {
                            showCustomSnackBar(
                                context, 'Please select the relevant options',
                                bottomMargin: 0);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          backgroundColor: const Color(0xFF1E889E),
                          textStyle: const TextStyle(
                            fontSize: 27,
                            fontFamily: 'Zilla',
                            fontWeight: FontWeight.w300,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.arrowsRotate,
                              size: 27,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Text('Update Chart'),
                          ],
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

  Widget buildBarChart() {
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
          width: statisticsResult.length <= 4
              ? 360
              : (80 * statisticsResult.length).toDouble(),
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: statisticsResult.values.reduce(max).toDouble() + padding,
                barGroups: getBarGroups(),
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
                    rotateAngle: 0,
                    getTextStyles: (context, value) => const TextStyle(
                      color: Color.fromARGB(163, 0, 0, 0),
                      fontSize: 14.5,
                    ),
                    reservedSize: reservedSizeForBottomTitles,
                    interval: 1,
                    getTitles: (value) {
                      if (value.toInt() >= 0 &&
                          value.toInt() < statisticsResult.length) {
                        final title =
                            statisticsResult.keys.elementAt(value.toInt());
                        final words = title.split(' ');
                        maxNumberOfWords = words.length > maxNumberOfWords
                            ? words.length
                            : maxNumberOfWords;
                        reservedSizeForBottomTitles =
                            calculateReservedSize(maxNumberOfWords);
                        return words.join('\n');
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

  Widget buildPieChart() {
    ScrollController scrollController = ScrollController();
    List<PieChartSectionData> sections = getSections();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 100.0),
          child: SizedBox(
            width: 150,
            height: 150,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 50,
                sectionsSpace: 0,
                startDegreeOffset: 180,
                centerSpaceColor: const Color.fromARGB(0, 30, 137, 158),
                borderData: FlBorderData(
                  show: false,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 100.0),
          child: statisticsResult.keys.length <= 3
              ? SizedBox(
                  height: 100,
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: statisticsResult.keys.map((city) {
                      return Container(
                        width: 300,
                        height: 40,
                        color: barColors[
                            statisticsResult.keys.toList().indexOf(city)],
                        child: Center(
                          child: Text(
                            city,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20),
                          ),
                        ),
                      );
                    }).toList(),
                  ))
              : SizedBox(
                  height: 140,
                  child: Scrollbar(
                    controller: scrollController,
                    trackVisibility: true,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      scrollDirection: Axis.vertical,
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 10.0,
                        children: statisticsResult.keys.map((city) {
                          return Container(
                            width: 300,
                            height: 40,
                            color: barColors[
                                statisticsResult.keys.toList().indexOf(city)],
                            child: Center(
                              child: Text(
                                city,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  List<PieChartSectionData> getSections() {
    int total = statisticsResult.values.reduce((a, b) => a + b);
    List<PieChartSectionData> sections = [];
    int i = 0;
    statisticsResult.forEach((city, count) {
      final double percentage = count.toDouble() / total;
      final double angle = percentage * 360;
      sections.add(
        PieChartSectionData(
          color: barColors[i],
          value: angle,
          title: '$count',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xffffffff),
          ),
          showTitle: true,
        ),
      );
      i++;
    });
    return sections;
  }

  List<BarChartGroupData> getBarGroups() {
    return statisticsResult.keys.map((city) {
      final int index = statisticsResult.keys.toList().indexOf(city);
      return BarChartGroupData(
        x: index,
        barsSpace: 8,
        barRods: [
          BarChartRodData(
            y: statisticsResult[city]!.toDouble(),
            colors: [barColors[index]],
            borderRadius: BorderRadius.zero,
            width: 40,
          ),
        ],
      );
    }).toList();
  }

  Widget _buildCircularIconButton(
      {required IconData icon, required Function() onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30.0),
        child: Ink(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1E889E).withOpacity(0.2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              icon,
              size: 30,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> updateChart() async {
    print("I have changed a selection!");
    final url =
        Uri.parse('https://touristine.onrender.com/get-statistics-test');

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
                      'Bethlehe': 50
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

enum ChartType {
  bar,
  pie,
}
