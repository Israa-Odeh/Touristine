import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image:
                AssetImage("assets/Images/Profiles/Tourist/homeBackground.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.reviews.length,
                itemBuilder: (context, index) {
                  return _buildReviewCard(widget.reviews[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Card(
      margin: const EdgeInsets.only(right: 10, left: 10, bottom: 10),
      color: const Color.fromARGB(68, 30, 137, 158),
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
                      fontSize: 35,
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
                        size: 22,
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
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Times New Roman',
                  color: Color.fromARGB(255, 21, 98, 113)),
            ),
            const SizedBox(height: 10),
            // Comment content
            Text(
              '${review['commentContent']}',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w100,
                  fontFamily: 'Zilla',
                  color: Color.fromARGB(255, 14, 63, 73)),
            ),
          ],
        ),
      ),
    );
  }
}
