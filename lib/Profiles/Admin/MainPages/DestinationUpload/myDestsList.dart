import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:touristine/Notifications/SnackBar.dart';
import 'package:touristine/Profiles/Tourist/MainPages/planMaker/customBottomSheet.dart';

class AddedDestinationsPage extends StatefulWidget {
  final String token;

  const AddedDestinationsPage({super.key, required this.token});

  @override
  _AddedDestinationsPageState createState() => _AddedDestinationsPageState();
}

class _AddedDestinationsPageState extends State<AddedDestinationsPage> {
  bool isLoading = true;

  List<Map<String, dynamic>> destinationsList = [
    {
      'name': 'Mar Saba Monastery',
      'image': 'https://www.bethlehem.edu/wp-content/uploads/2020/03/5-1.jpg',
      'city': 'Bethlehem',
      'category': 'Religious Landmark',
    },
    {
      'name': 'Sufi Cafe',
      'image':
          'https://i.pinimg.com/736x/74/59/4d/74594def71eb01f598366e091ea53e4a.jpg',
      'city': 'Ramallah',
      'category': 'Others',
    }
  ];

  @override
  void initState() {
    super.initState();
    fetchAddedDestinations();
  }

  void fetchAddedDestinations() async {
    print("Fetching Destinations................");
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    final url =
        Uri.parse('https://touristine.onrender.com/get-added-destinations');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'filter':
              selectedFilter == "Select a Filter" ? 'all' : selectedFilter.toLowerCase().replaceAll(" ", ""),
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Jenan, here I need to retrieve a List<Map> of destinations
        // similar to the format shown at line 19.
      } else if (response.statusCode == 500) {
        // Israa, Handle 500 status code
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Error retrieving the destinations',
            bottomMargin: 0);
      }
    } catch (error) {
      if (mounted) {
        print('Error fetching the destinations: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildCard(
      String destinationName, String imagePath, String city, String category) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  imagePath,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.fill,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.8),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destinationName,
                        style: const TextStyle(
                          fontFamily: 'Andalus',
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const Divider(
                        thickness: 3,
                        color: Color.fromARGB(80, 19, 83, 96),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            city,
                            style: const TextStyle(
                              fontFamily: 'Zilla',
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Text(
                            category,
                            style: const TextStyle(
                              fontFamily: 'Zilla',
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                buildButton(
                  FontAwesomeIcons.anglesRight,
                  const Color.fromARGB(255, 231, 231, 231),
                  const Color.fromARGB(255, 0, 0, 0),
                  () {
                    // Israa, here navigate to the clicked destination page.
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> filteringList = [
    'Jerusalem',
    'Nablus',
    'Ramallah',
    'Bethlehem',
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
  ];

  String selectedFilter = 'Select a Filter';

  void showFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return CustomBottomSheet(itemsList: filteringList, height: 400);
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          selectedFilter = value;
        });
        fetchAddedDestinations();
      }
    });
  }

  Widget buildButton(
    IconData buttonIcon,
    Color btnColor,
    Color btnTxtColor,
    VoidCallback onPressedFunction,
  ) {
    return ElevatedButton(
      onPressed: onPressedFunction,
      style: ElevatedButton.styleFrom(
        backgroundColor: btnColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15.0),
            bottomRight: Radius.circular(15.0),
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              buttonIcon,
              size: 24,
              color: btnTxtColor,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/Images/Profiles/Admin/mainBackground.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (destinationsList.isNotEmpty && !isLoading)
                Padding(
                  padding: const EdgeInsets.only(
                      right: 20, left: 20.0, top: 15, bottom: 10),
                  child: ElevatedButton(
                    onPressed: showFiltersBottomSheet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 231, 231, 231),
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
                              selectedFilter,
                              style: const TextStyle(
                                color: Color.fromARGB(163, 0, 0, 0),
                                fontSize: 22,
                              ),
                            ),
                          ),
                          const FaIcon(
                            FontAwesomeIcons.list,
                            color: Color.fromARGB(100, 0, 0, 0),
                            size: 25,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF1E889E)),
                        ),
                      )
                    : destinationsList.isEmpty
                        ? Center(
                            child: Column(
                              children: [
                                const SizedBox(height: 72),
                                Image.asset(
                                  'assets/Images/Profiles/Tourist/emptyListTransparent.gif',
                                  fit: BoxFit.cover,
                                ),
                                const Text(
                                  'No destinations found',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Gabriola',
                                    color: Color.fromARGB(255, 23, 99, 114),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 16),
                            children: destinationsList.map((destinationData) {
                              final destinationName = destinationData['name'];
                              final imagePath = destinationData['image'];
                              final city = destinationData['city'];
                              final category = destinationData['category'];
                              return Column(
                                children: [
                                  _buildCard(destinationName, imagePath, city,
                                      category),
                                  const SizedBox(height: 10),
                                ],
                              );
                            }).toList(),
                          ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
