import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:touristine/Notifications/SnackBar.dart';
import 'package:http/http.dart' as http;

class AddingReviewPage extends StatefulWidget {
  @override
  _AddingReviewPageState createState() => _AddingReviewPageState();
}

class _AddingReviewPageState extends State<AddingReviewPage> {
  int selectedStars = 0;
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  // Function to validate the form
  bool validateForm() {
    if (selectedStars == 0) {
      // Stars evaluation not selected.
      showCustomSnackBar(context, 'Please select a star rating',
          bottomMargin: 370);
      return false;
    }

    if (titleController.text.isEmpty) {
      // Review title or content not filled.
      showCustomSnackBar(context, 'Please enter the review title',
          bottomMargin: 370);
      return false;
    }

    if (contentController.text.isEmpty) {
      // Review title or content not filled.
      showCustomSnackBar(context, 'Please enter the review content',
          bottomMargin: 370);
      return false;
    }

    if (titleController.text.length < 5) {
      // Review title or content not filled.
      showCustomSnackBar(context, 'Title must have at least 5 characters',
          bottomMargin: 370);
      return false;
    }

    if (contentController.text.length < 20) {
      // Review title or content not filled.
      showCustomSnackBar(context, 'Content must have at least 20 chars',
          bottomMargin: 370);
      return false;
    }
    // Form is valid.
    return true;
  }

  // Function to send the review data to the backend.
  Future<void> sendReviewData() async {
    final url = Uri.parse('https://touristine.onrender.com/sendReviewData');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          // 'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'stars': selectedStars.toString(),
          'title': titleController.text,
          'content': contentController.text,
        },
      );

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Thank you for adding your review',
            bottomMargin: 370);
      } 
      else {
        // Handle other status codes or errors
        print('Failed to submit review. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle network or other errors
      print('Error sending review: $error');
    }
  }

  // A function to retrieve the user's review data.
  Future<void> getReviewData() async {
    final url = Uri.parse('https://touristine.onrender.com/getReviewData');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          // 'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        /* final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          selectedStars = int.parse(responseData['stars']);
          titleController.text = responseData['title'];
          contentController.text = responseData['content'];
        });
        */
      } else if (response.statusCode == 500) {
        // Failed.
      } else {
        // ignore: use_build_context_synchronously
        // showCustomSnackBar(context, "Failed to fetch recommendations",
        //     bottomMargin: 0);
      }
    } catch (error) {
      print('Failed to fetch your review: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    getReviewData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Center(
                child: Image.asset(
                  'assets/Images/Profiles/Tourist/review.gif',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 11),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => IconButton(
                      icon: Icon(
                        index < selectedStars
                            ? FontAwesomeIcons.solidStar
                            : FontAwesomeIcons.star,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        setState(() {
                          if (index == 0 && selectedStars == 1) {
                            selectedStars = 0;
                          } 
                          else {
                            selectedStars = index + 1;
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Review Title',
                  labelStyle: TextStyle(
                    fontSize: 25,
                    color: Color(0xFF1E889E),
                    fontWeight: FontWeight.bold,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF1E889E)),
                  ),
                ),
                maxLength: 34,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Review Content',
                  labelStyle: TextStyle(
                    fontSize: 25,
                    color: Color(0xFF1E889E),
                    fontWeight: FontWeight.bold,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF1E889E)),
                  ),
                ),
                minLines: 1,
                maxLines: 5,
                maxLength: 1000,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: IconButton(
                icon: const FaIcon(
                  FontAwesomeIcons.arrowLeft,
                  color: Color(0xFF1E889E),
                  size: 30,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (validateForm()) {
                  sendReviewData();
                  print('Stars: $selectedStars');
                  print('Title: ${titleController.text}');
                  print('Content: ${contentController.text}');
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                backgroundColor: const Color(0xFF1E889E),
                textStyle: const TextStyle(
                  fontSize: 25,
                  fontFamily: 'Zilla',
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Add Review'),
            ),
          ],
        ),
      ],
    );
  }
}
