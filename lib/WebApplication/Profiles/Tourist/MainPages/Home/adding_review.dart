import 'package:touristine/WebApplication/Notifications/snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class AddingReviewPage extends StatefulWidget {
  final String token;
  final String destinationName;
  final int reviewStars;
  final String reviewTitle;
  final String reviewContent;
  final Function onReviewAdded;

  const AddingReviewPage(
      {super.key,
      required this.token,
      required this.destinationName,
      this.reviewStars = 0,
      this.reviewTitle = "",
      this.reviewContent = "",
      required this.onReviewAdded});
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
          bottomMargin: 0);
      return false;
    }

    if (titleController.text.isEmpty) {
      // Review title or content not filled.
      showCustomSnackBar(context, 'Please enter the review title',
          bottomMargin: 0);
      return false;
    }

    if (contentController.text.isEmpty) {
      // Review title or content not filled.
      showCustomSnackBar(context, 'Please enter the review content',
          bottomMargin: 0);
      return false;
    }

    if (titleController.text.length < 5) {
      // Review title or content not filled.
      showCustomSnackBar(context, 'Title must have at least 5 characters',
          bottomMargin: 0);
      return false;
    }

    if (contentController.text.length < 20) {
      // Review title or content not filled.
      showCustomSnackBar(context, 'Content must have at least 20 characters',
          bottomMargin: 0);
      return false;
    }
    // Form is valid.
    return true;
  }

  // Function to send the review data to the backend.
  Future<void> sendReviewData() async {
    String currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final url = Uri.parse('https://touristineapp.onrender.com/send-review-data');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'destinationName': widget.destinationName,
          'stars': selectedStars.toString(),
          'title': titleController.text,
          'content': contentController.text,
          'date': currentDate,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['message'] == "Your review was saved") {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, 'Thanks for sharing your review',
              bottomMargin: 0);
          // Call the callback to trigger getDestinationDetails.
          widget.onReviewAdded();
        } else {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, 'Your review has been updated',
              bottomMargin: 0);
          widget.onReviewAdded();
        }
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('error')) {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
        } else {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, responseData['message'],
              bottomMargin: 0);
        }
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Error storing your review',
            bottomMargin: 0);
      }
    } catch (error) {
      // Handle network or other errors
      print('Error sending review: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    selectedStars = widget.reviewStars;
    titleController.text = widget.reviewTitle;
    contentController.text = widget.reviewContent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/Images/Profiles/Tourist/review.gif',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                } else {
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
                          fontSize: 20,
                          color: Color(0xFF1E889E),
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
                          fontSize: 20,
                          color: Color(0xFF1E889E),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF1E889E)),
                        ),
                      ),
                      minLines: 1,
                      maxLines: 7,
                      maxLength: 1000,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
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
                  size: 20,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (validateForm()) {
                  await sendReviewData();
                  print('Stars: $selectedStars');
                  print('Title: ${titleController.text}');
                  print('Content: ${contentController.text}');
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 20,
                ),
                backgroundColor: const Color(0xFF1E889E),
                textStyle: const TextStyle(
                  fontSize: 20,
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
