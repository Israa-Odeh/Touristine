import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

class UploadedImagesPage extends StatefulWidget {
  final String token;
  final String destinationName;
  final List<Map<String, dynamic>> uploadedImages;
  final int minImagesToShowScrollbar = 3;

  const UploadedImagesPage(
      {super.key,
      required this.token,
      required this.destinationName,
      required this.uploadedImages});

  @override
  _UploadedImagesPageState createState() => _UploadedImagesPageState();
}

class _UploadedImagesPageState extends State<UploadedImagesPage> {
  // A function to delete a specific upload.
  Future<void> deleteUploadedImages(int uploadID) async {
    final url =
        Uri.parse('https://touristine.onrender.com/deleteuploads/$uploadID');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'destinationName': widget.destinationName,
        },
      );

      if (response.statusCode == 200) {
        // Success.
        // Perform handling stuff later on....
      } else {
        print(
            'Failed to delete the uplaod. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error deleting the upload: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image:
                AssetImage("assets/Images/Profiles/Tourist/homeBackground.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: widget.uploadedImages.length,
            itemBuilder: (context, index) {
              final imageInfo = widget.uploadedImages[index];
              final List<String> keywords =
                  (imageInfo['keywords'] as String).split(',');
              final String uploadingDate = imageInfo['date'];
              final List<String> imageUrls =
                  List<String>.from(imageInfo['imageUrls']);
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Card(
                  color: const Color.fromARGB(68, 30, 137, 158),
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Categories: ${keywords.join(', ')}',
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w100,
                              fontFamily: 'Zilla',
                              color: Color.fromARGB(255, 14, 63, 73)),
                        ),
                        // const SizedBox(height: 5,),
                        const Divider(
                          color: Color.fromARGB(126, 14, 63, 73),
                          thickness: 2,
                        ),
                        SizedBox(
                          height: 200,
                          child: imageUrls.length >=
                                  widget.minImagesToShowScrollbar
                              ? Scrollbar(
                                  trackVisibility: true,
                                  thumbVisibility: true,
                                  controller: scrollController,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: imageUrls.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            right: 8.0,
                                            left: 8.0,
                                            top: 8.0,
                                            bottom: 15.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          child: Image.network(
                                            imageUrls[index],
                                            width: 160,
                                            height: 110,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : ListView.builder(
                                  controller: scrollController,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: imageUrls.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        child: Image.network(
                                          imageUrls[index],
                                          width: 160,
                                          height: 110,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        const Divider(
                          color: Color.fromARGB(126, 14, 63, 73),
                          thickness: 2,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              uploadingDate,
                              style: const TextStyle(
                                  fontSize: 19.5,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Time New Roman',
                                  color: Color.fromARGB(255, 14, 63, 73)),
                            ),
                            Text(
                              imageInfo['status'],
                              style: const TextStyle(
                                  fontSize: 19.5,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Time New Roman',
                                  color: Color.fromARGB(255, 14, 63, 73)),
                            ),
                          ],
                        ),
                        Visibility(
                          visible: imageInfo['status'].toLowerCase() == 'approved'? false: true,
                          child: const Divider(
                            color: Color.fromARGB(126, 14, 63, 73),
                            thickness: 2,
                          ),
                        ),
                        Visibility(
                          visible: imageInfo['status'].toLowerCase() == 'approved'? false: true,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                color: const Color(0xFF1E889E),
                                icon: const FaIcon(FontAwesomeIcons.trash),
                                onPressed: () {
                                  print(widget.uploadedImages[index]['uploadID']);
                                  deleteUploadedImages(
                                      widget.uploadedImages[index]['uploadID']);
                                },
                              ),
                            ],
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'GoBack',
        onPressed: () {
          Navigator.of(context).pop();
        },
        backgroundColor: const Color.fromARGB(129, 30, 137, 158),
        elevation: 0,
        child: const Icon(FontAwesomeIcons.arrowLeft),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
