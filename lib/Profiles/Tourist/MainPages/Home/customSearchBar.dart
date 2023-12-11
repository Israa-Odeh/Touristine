import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:touristine/Notifications/SnackBar.dart';
import 'package:touristine/Profiles/Tourist/MainPages/Home/SearchedDests.dart';

class CustomSearchBar extends StatefulWidget {
  final String token;

  const CustomSearchBar({super.key, required this.token});

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController searchController = TextEditingController();

  bool isBudgetFriendly = false;
  bool isMidRange = false;
  bool isLuxurious = false;
  bool no = false;
  bool yes = false;

  final List<String> originalSuggestions = [
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
  List<String> filteredSuggestions = [];
  Color iconColor = Colors.grey;

  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    filteredSuggestions = originalSuggestions;
  }

  @override
  void dispose() {
    super.dispose();
  }

  // A function to send a search request to the backend.
  Future<void> sendSearchRequest(String query) async {
    if (mounted) {
      setState(() {
        isSearching = true;
      });
    }
    final url = Uri.parse('https://touristine.onrender.com/search-destination');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'searchTerm': query,
          'isBudgetFriendly': isBudgetFriendly.toString(),
          'isMidRange': isMidRange.toString(),
          'isLuxurious': isLuxurious.toString(),
          'Sheltered': yes ? yes.toString() : "false"
        },
      );

      if (response.statusCode == 200) {
        // Success.
        final Map<String, dynamic> responseData = json.decode(response.body);
        List<dynamic> rawDestinationsList = responseData['destinationsList'];

        List<Map<String, dynamic>> destinationsList =
            List<Map<String, dynamic>>.from(rawDestinationsList);

        print(destinationsList);
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchedDestinations(
              token: widget.token,
              destinationsList: destinationsList,
            ),
          ),
        );
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, responseData['error'], bottomMargin: 350);
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Failed to retrieve search results',
            bottomMargin: 350);
      }
    } catch (error) {
      print('Failed to send search request: $error');
    } finally {
      if (mounted) {
        setState(() {
          isSearching = false;
        });
      }
    }
  }

  void submitSearch() {
    String query = searchController.text;
    if (query.isNotEmpty) {
      if (RegExp(r'^[a-zA-Z0-9_-\s]+$').hasMatch(query)) {
        sendSearchRequest(query);
      } else {
        showCustomSnackBar(context, 'Invalid characters in search query!',
            bottomMargin: 300);
      }
    } else {
      showCustomSnackBar(context, 'Enter a search query!', bottomMargin: 300);
    }
  }

  void clearSearch() {
    setState(() {
      searchController.clear();
      updateSuggestions('');
    });
  }

  void showFilterOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Filtering Options',
                style: TextStyle(
                  color: Color.fromARGB(255, 12, 53, 61),
                  fontFamily: 'Zilla',
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ListTile(
                      title: Text(
                        'Budget Level',
                        style: TextStyle(
                          color: Color.fromARGB(255, 12, 53, 61),
                          fontFamily: 'Zilla Slab Light',
                          fontWeight: FontWeight.bold,
                          fontSize: 23,
                        ),
                      ),
                    ),
                    CheckboxListTile(
                      title: const Text('Budget-friendly'),
                      value: isBudgetFriendly,
                      activeColor: const Color(0xFF1E889E),
                      onChanged: (bool? value) {
                        setState(() {
                          isBudgetFriendly = value ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Mid-range'),
                      value: isMidRange,
                      activeColor: const Color(0xFF1E889E),
                      onChanged: (bool? value) {
                        setState(() {
                          isMidRange = value ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Luxurious'),
                      value: isLuxurious,
                      activeColor: const Color(0xFF1E889E),
                      onChanged: (bool? value) {
                        setState(() {
                          isLuxurious = value ?? false;
                        });
                      },
                    ),
                    const Divider(
                      thickness: 4,
                      color: Color.fromARGB(147, 178, 181, 181),
                    ),
                    const ListTile(
                      title: Text(
                        'Sheltered Places?',
                        style: TextStyle(
                          color: Color.fromARGB(255, 12, 53, 61),
                          fontFamily: 'Zilla Slab Light',
                          fontWeight: FontWeight.bold,
                          fontSize: 23,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('Yes'),
                            value: yes,
                            activeColor: const Color(0xFF1E889E),
                            onChanged: (bool? value) {
                              setState(() {
                                yes = value ?? false;
                                no = false;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('No'),
                            value: no,
                            activeColor: const Color(0xFF1E889E),
                            onChanged: (bool? value) {
                              setState(() {
                                no = value ?? false;
                                yes = false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 22.0,
                          fontFamily: 'Zilla',
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 200, 50, 27),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Image.asset(
            'assets/Images/Profiles/Tourist/homeBackground.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 16.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(143, 239, 239, 239),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: const Color(0xFF1E889E),
                      width: 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Focus(
                          onFocusChange: (hasFocus) {
                            setState(() {
                              iconColor = hasFocus
                                  ? const Color(0xFF1E889E)
                                  : Colors.grey;
                            });
                          },
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: const TextStyle(fontSize: 22),
                              border: InputBorder.none,
                              icon: FaIcon(
                                FontAwesomeIcons.magnifyingGlass,
                                color: iconColor,
                              ),
                            ),
                            style: const TextStyle(fontSize: 22),
                            onChanged: (value) {
                              updateSuggestions(value);
                            },
                            onSubmitted: (value) => submitSearch(),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const FaIcon(FontAwesomeIcons.list),
                            onPressed: () {
                              showFilterOptionsDialog(context);
                            },
                          ),
                          IconButton(
                            icon: const FaIcon(FontAwesomeIcons.xmark),
                            onPressed: clearSearch,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                buildSuggestionsList(),
                const SizedBox(height: 16),
                if (isSearching)
                  const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF1E889E)),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'BackToHome',
        onPressed: () {
          Navigator.of(context).pop();
        },
        backgroundColor: const Color(0xFF1E889E),
        elevation: 0,
        child: const Icon(FontAwesomeIcons.arrowLeft),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  void updateSuggestions(String value) {
    setState(() {
      filteredSuggestions = getFilteredSuggestions(value);
    });
  }

  List<String> getFilteredSuggestions(String query) {
    if (query.isEmpty) {
      return originalSuggestions;
    }
    return originalSuggestions
        .where((suggestion) =>
            suggestion.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Widget buildSuggestionsList() {
    return filteredSuggestions.isEmpty
        ? Container()
        : Card(
            color: const Color.fromARGB(147, 255, 255, 255),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: const BorderSide(color: Color(0xFF1E889E)),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = filteredSuggestions[index];
                return ListTile(
                  title: Text(suggestion,
                      style:
                          const TextStyle(fontSize: 24, fontFamily: 'Andalus')),
                  onTap: () {
                    searchController.text = suggestion;
                    updateSuggestions(searchController.text);
                    submitSearch();
                  },
                );
              },
            ),
          );
  }
}
