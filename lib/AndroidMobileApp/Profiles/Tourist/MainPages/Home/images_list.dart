import 'package:touristine/AndroidMobileApp/Profiles/Tourist/MainPages/Home/dots_bar.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class ImagesList extends StatefulWidget {
  final List<Map<String, dynamic>> listOfImages;
  final Function(String) onImageSelected;

  const ImagesList(
      {super.key, required this.listOfImages, required this.onImageSelected});

  @override
  _OtherPlacesState createState() => _OtherPlacesState();
}

class _OtherPlacesState extends State<ImagesList> {
  int _currentPageIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    print(widget.listOfImages);

    // Set up a timer for automatic scrolling every 5 seconds.
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (mounted) {
        if (_currentPageIndex < widget.listOfImages.length - 1) {
          setState(() {
            _currentPageIndex++;
          });
        } else {
          // If we are at the last page, go back to the first page.
          setState(() {
            _currentPageIndex = 0;
          });
        }
        // Call the callback function to change the image.
        widget.onImageSelected(widget.listOfImages[_currentPageIndex]['image']);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      widget.onImageSelected(widget.listOfImages[_currentPageIndex]['image']);
    });
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            height: 95,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.listOfImages.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    widget.onImageSelected(widget.listOfImages[index]['image']);
                    setState(() {
                      _currentPageIndex = index;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Card(
                      color: const Color.fromARGB(71, 111, 228, 252),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          color: Color(0xFF1E889E),
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          widget.listOfImages[index]['image'],
                          width: 83,
                          height: 83,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          DotsBar(
            itemCount: widget.listOfImages.length,
            currentIndex: _currentPageIndex,
          ),
        ],
      ),
    );
  }
}
