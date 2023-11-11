import 'dart:async';
import 'package:flutter/material.dart';
import 'package:touristine/Profiles/Tourist/MainPages/Home/dotsBar.dart';

class DestinationList extends StatefulWidget {
  final List<Map<String, dynamic>> destinations;
  final String listTitle;

  const DestinationList(
      {super.key, required this.destinations, required this.listTitle});

  @override
  _DestinationListState createState() => _DestinationListState();
}

class _DestinationListState extends State<DestinationList> {
  final PageController _pageController = PageController();
  int _selectedTileIndex = -1;
  int _currentPageIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Set up a timer for automatic scrolling every 5 seconds.
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPageIndex < widget.destinations.length - 1) {
        _pageController.nextPage(
          // The animation lasts for the given duration and follows the given curve.
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      } else {
        // If we are at the last page, go back to the first page.
        _pageController.jumpToPage(0);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ),
            child: Text(
              widget.listTitle,
              style: const TextStyle(
                fontSize: 38,
                fontFamily: 'Gabriola',
                color: Color(0xFF1E889E),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              height: 230,
              width: 400,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.destinations.length,
                onPageChanged: (int index) {
                  setState(() {
                    _currentPageIndex = index;
                  });
                },
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    // Israa, open the appropriate interfaces here.
                    onTap: () {
                      setState(() {
                        if (_selectedTileIndex == index) {
                          _selectedTileIndex = -1; // Deselect if already selected.
                        } 
                        else {
                          _selectedTileIndex = index; // Select if not selected.
                        }
                      });
                      print('Clicked on ${widget.destinations[index]['name']}');
                    },
                    child: Container(
                      margin: const EdgeInsets.all(0),
                      child: Card(
                        color: _selectedTileIndex == index
                            ? const Color(0xFF1E889E)
                            : const Color.fromARGB(255, 255, 255, 255),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              color: Color(0xFF1E889E), width: 3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            Image.asset(
                              widget.destinations[index]['image'],
                              width: 400,
                              height: 165,
                              fit: BoxFit.cover,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                widget.destinations[index]['name'],
                                style: TextStyle(
                                  color: _selectedTileIndex == index
                                      ? Colors.white
                                      : const Color(0xFF1E889E),
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Zilla',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          DotsBar(
            itemCount: widget.destinations.length,
            currentIndex: _currentPageIndex,
          ),
        ],
      ),
    );
  }
}