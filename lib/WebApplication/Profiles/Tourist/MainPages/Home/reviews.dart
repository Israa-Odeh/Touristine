import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

class AllReviewsPage extends StatefulWidget {
  final List<Map<String, dynamic>> reviews;

  const AllReviewsPage({Key? key, required this.reviews}) : super(key: key);

  @override
  _AllReviewsPageState createState() => _AllReviewsPageState();
}

class _AllReviewsPageState extends State<AllReviewsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.reviews.isEmpty ? Colors.white : null,
      body: Container(
        decoration: BoxDecoration(
            image: widget.reviews.isNotEmpty
                ? const DecorationImage(
                    image: AssetImage(
                        "assets/Images/Profiles/Tourist/homeBackground.jpg"),
                    fit: BoxFit.fill,
                  )
                : null),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: widget.reviews.isEmpty
                  ? Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: -50,
                            child: Image.asset(
                              'assets/Images/Profiles/Tourist/emptyList.gif',
                              fit: BoxFit.fill,
                            ),
                          ),
                          const Positioned(
                            top: 420,
                            child: Text(
                              'No reviews found',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Gabriola',
                                color: Color.fromARGB(255, 23, 99, 114),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: widget.reviews.length,
                      itemBuilder: (context, index) {
                        return _buildReviewCard(widget.reviews[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding:
            EdgeInsets.only(bottom: widget.reviews.isNotEmpty ? 0.0 : 10.0),
        child: FloatingActionButton(
          heroTag: 'GoBack',
          onPressed: () {
            Navigator.of(context).pop();
          },
          backgroundColor: widget.reviews.isNotEmpty
              ? const Color.fromARGB(129, 30, 137, 158)
              : const Color(0xFF1E889E),
          elevation: 0,
          child: const Icon(FontAwesomeIcons.arrowLeft),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Card(
      margin: const EdgeInsets.only(right: 10, left: 10, bottom: 10),
      color: const Color.fromARGB(61, 141, 148, 149),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User details and Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // User details
                Text(
                  '${review['firstName']} ${review['lastName']}',
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Gabriola',
                      color: Color.fromARGB(199, 13, 60, 69)),
                ),
                // Star icons
                Row(
                  children: List.generate(
                    review['stars'],
                    (index) => const Padding(
                      padding: EdgeInsets.only(right: 3),
                      child: Icon(
                        FontAwesomeIcons.solidStar,
                        color: Color.fromARGB(255, 211, 171, 12),
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Divider line
            const Divider(
              color: Color.fromARGB(126, 14, 63, 73),
              thickness: 2,
            ),
            const SizedBox(height: 20),
            // Comment title
            Text(
              '${review['commentTitle']}',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Times New Roman',
                  color: Color.fromARGB(255, 21, 98, 113)),
            ),
            const SizedBox(height: 10),
            // Comment content
            Text(
              '${review['commentContent']}',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w100,
                  fontFamily: 'Time New Roman',
                  color: Color.fromARGB(255, 14, 63, 73)),
            ),
            const SizedBox(height: 10),
            // Date
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '${review['date']}',
                style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Time New Roman',
                    color: Color.fromARGB(255, 14, 63, 73)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
