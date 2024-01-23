import 'package:touristine/AndroidMobileApp/Profiles/Tourist/MainPages/planMaker/custom_bottom_sheet.dart';
import 'package:touristine/AndroidMobileApp/Notifications/snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  final String token;
  Map<String, int> statisticsResult;
  String selectedCity;
  String selectedCategory;
  String selectedStatisticsType;

  HomePage(
      {super.key,
      required this.token,
      required this.statisticsResult,
      required this.selectedCity,
      required this.selectedCategory,
      required this.selectedStatisticsType});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double reservedSizeForBottomTitles = 30;
  int maxNumberOfWords = 0;

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

  double padding = 0;

  List<String> statisticsList = [
    'Visits Count',
    'Reviews Count',
    'Complaints Count',
    'Ratings Count'
  ];

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
          widget.selectedStatisticsType = value;
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

  String getPlaceCategory(String placeCategory) {
    if (placeCategory.toLowerCase() == "coastalareas") {
      return "Coastal Areas";
    } else if (placeCategory.toLowerCase() == "mountains") {
      return "Mountains";
    } else if (placeCategory.toLowerCase() == "nationalparks") {
      return "National Parks";
    } else if (placeCategory.toLowerCase() == "majorcities") {
      return "Major Cities";
    } else if (placeCategory.toLowerCase() == "countryside") {
      return "Countryside";
    } else if (placeCategory.toLowerCase() == "historicalsites") {
      return "Historical Sites";
    } else if (placeCategory.toLowerCase() == "religiouslandmarks") {
      return "Religious Landmarks";
    } else if (placeCategory.toLowerCase() == "aquariums") {
      return "Aquariums";
    } else if (placeCategory.toLowerCase() == "zoos") {
      return "Zoos";
    } else if (placeCategory.toLowerCase() == "others") {
      return "Others";
    } else {
      return placeCategory;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.statisticsResult.isNotEmpty) {
      double maxVisits = widget.statisticsResult.values.reduce(max).toDouble();
      double maxPaddingThreshold = 10000;
      padding = maxVisits > 0 ? min(maxVisits * 0.1, maxPaddingThreshold) : 1.0;
    }

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
                                widget.selectedStatisticsType.isEmpty
                                    ? 'Select Statistic Type'
                                    : widget.selectedStatisticsType,
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
                    mainAxisAlignment: selectedChartType == ChartType.bar &&
                            widget.statisticsResult.isNotEmpty
                        ? MainAxisAlignment.end
                        : selectedChartType == ChartType.pie &&
                                widget.statisticsResult.isNotEmpty
                            ? MainAxisAlignment.spaceAround
                            : MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 35.0),
                        child: DropdownButton<String>(
                          value: widget.selectedCity,
                          icon: const Icon(
                            FontAwesomeIcons.caretDown,
                            color: Color.fromARGB(104, 0, 0, 0),
                          ),
                          items: [
                            'All Cities',
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
                              widget.selectedCity = value ?? 'All Cities';
                            });
                          },
                        ),
                      ),
                      if (widget.selectedCity == "All Cities")
                        DropdownButton<String>(
                          value: widget.selectedCategory,
                          icon: const Icon(
                            FontAwesomeIcons.caretDown,
                            color: Color.fromRGBO(0, 0, 0, 0.5),
                          ),
                          items: (getCategoriesListForAllChoice())
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            if (value != null) {
                              setState(() {
                                widget.selectedCategory = value;
                              });
                            }
                          },
                        ),
                      if (widget.selectedCity != "All Cities")
                        DropdownButton<String>(
                          value: widget.selectedCategory == "By City"
                              ? "By Category"
                              : widget.selectedCategory,
                          icon: const Icon(
                            FontAwesomeIcons.caretDown,
                            color: Color.fromRGBO(0, 0, 0, 0.5),
                          ),
                          items: (getCategoriesListForNonAll())
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            if (value != null) {
                              setState(() {
                                widget.selectedCategory = value;
                              });
                            }
                          },
                        )
                    ],
                  ),
                  if (widget.statisticsResult.isNotEmpty)
                    SizedBox(
                      height: selectedChartType == ChartType.bar ? 450 : 490,
                      child: (widget.statisticsResult.length > 4 &&
                              selectedChartType == ChartType.bar)
                          ? Scrollbar(
                              trackVisibility: true,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: buildBarChart(),
                              ),
                            )
                          : selectedChartType == ChartType.bar
                              ? buildBarChart()
                              : buildPieChart(),
                    )
                  else
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                            'assets/Images/Profiles/Tourist/emptyListTransparent.gif',
                            fit: BoxFit.fill),
                        const Text(
                          'No results found',
                          style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Gabriola',
                              color: Color.fromARGB(255, 23, 99, 114)),
                        ),
                        if (selectedChartType == ChartType.bar)
                          const SizedBox(height: 36.5),
                        if (selectedChartType == ChartType.pie)
                          const SizedBox(height: 30.5)
                      ],
                    ),
                  if (selectedChartType == ChartType.bar &&
                      widget.statisticsResult.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 70),
                      child: Text(
                        widget.selectedCategory,
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
                  if (widget.statisticsResult.length <= 10)
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
                              if (widget.selectedStatisticsType.isNotEmpty &&
                                  widget.selectedCity.isNotEmpty &&
                                  widget.selectedCategory.isNotEmpty) {
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
                              if (widget.selectedStatisticsType.isNotEmpty &&
                                  widget.selectedCity.isNotEmpty &&
                                  widget.selectedCategory.isNotEmpty) {
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
                  if (widget.statisticsResult.length > 10)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 70.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (widget.selectedStatisticsType.isNotEmpty &&
                              widget.selectedCity.isNotEmpty &&
                              widget.selectedCategory.isNotEmpty) {
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
              widget.selectedStatisticsType.isEmpty
                  ? 'Visits Count'
                  : widget.selectedStatisticsType,
              style: const TextStyle(
                  color: Color.fromARGB(163, 0, 0, 0),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Zilla Slab Light'),
            ),
          ),
        ),
        SizedBox(
          width: widget.statisticsResult.length <= 4
              ? 360
              : (80 * widget.statisticsResult.length).toDouble(),
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: widget.statisticsResult.values.reduce(max).toDouble() >= 8
                    ? widget.statisticsResult.values.reduce(max).toDouble() +
                        padding
                    : 10,
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
                          value.toInt() < widget.statisticsResult.length) {
                        final title = widget.statisticsResult.keys
                            .elementAt(value.toInt());
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
          child: widget.statisticsResult.keys.length <= 3
              ? SizedBox(
                  height: 100,
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: widget.statisticsResult.keys.map((city) {
                      return Container(
                        width: 300,
                        height: 40,
                        color: barColors[widget.statisticsResult.keys
                            .toList()
                            .indexOf(city)],
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
                        children: widget.statisticsResult.keys.map((city) {
                          return Container(
                            width: 300,
                            height: 40,
                            color: barColors[widget.statisticsResult.keys
                                .toList()
                                .indexOf(city)],
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
    int total = widget.statisticsResult.values.reduce((a, b) => a + b);
    List<PieChartSectionData> sections = [];
    int i = 0;
    widget.statisticsResult.forEach((city, count) {
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
    return widget.statisticsResult.keys.map((city) {
      final int index = widget.statisticsResult.keys.toList().indexOf(city);
      return BarChartGroupData(
        x: index,
        barsSpace: 8,
        barRods: [
          BarChartRodData(
            y: widget.statisticsResult[city]!.toDouble(),
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
    final url = Uri.parse('https://touristineapp.onrender.com/get-statistics');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'StatisticType': widget.selectedStatisticsType.isNotEmpty
              ? widget.selectedStatisticsType
              : 'Visits Count',
          'city': widget.selectedCity == "All Cities"
              ? "allcities"
              : widget.selectedCity,
          'category': widget.selectedCity != "All Cities" &&
                  widget.selectedCategory == "By City"
              ? 'bycategory'
              : widget.selectedCategory.toLowerCase().replaceAll(' ', '')
        },
      );

      if (response.statusCode == 200) {
        // Israa, here you must handle the state of
        // the chart to be updated with the new data.
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> graphData = responseData['graphData'];

        // Map the data to categories using getPlaceCategory function
        final Map<String, int> newStatisticsResult = {};
        for (var item in graphData) {
          if (item is Map<String, dynamic> && item.length == 1) {
            final String key = item.keys.first;
            final double value = item.values.first.toDouble();
            final String category = getPlaceCategory(key);
            newStatisticsResult[category] = value.toInt();
          }
        }
        setState(() {
          widget.statisticsResult.clear();
          widget.statisticsResult =
              Map.fromEntries(newStatisticsResult.entries);
        });

        print(widget.statisticsResult);
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Error finding a result', bottomMargin: 0);
      }
    } catch (error) {
      print('Error during finding a result: $error');
    }
  }
}

enum ChartType {
  bar,
  pie,
}
