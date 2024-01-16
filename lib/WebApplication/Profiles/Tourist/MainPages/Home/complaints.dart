import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

class ComplaintsListPage extends StatefulWidget {
  final String token;
  final List<Map<String, dynamic>> complaints;

  const ComplaintsListPage(
      {super.key, required this.token, required this.complaints});

  @override
  _ComplaintsListPageState createState() => _ComplaintsListPageState();
}

class _ComplaintsListPageState extends State<ComplaintsListPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.complaints.isEmpty ? Colors.white : null,
      body: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            image: widget.complaints.isNotEmpty
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
              child: widget.complaints.isEmpty
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
                              'No complaints found',
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
                      itemCount: widget.complaints.length,
                      itemBuilder: (context, index) {
                        return ComplaintCard(
                            complaint: widget.complaints[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding:
            EdgeInsets.only(bottom: widget.complaints.isNotEmpty ? 0.0 : 10.0),
        child: FloatingActionButton(
          heroTag: 'GoBack',
          onPressed: () {
            Navigator.of(context).pop();
          },
          backgroundColor: widget.complaints.isNotEmpty
              ? const Color.fromARGB(129, 30, 137, 158)
              : const Color(0xFF1E889E),
          elevation: 0,
          child: const Icon(FontAwesomeIcons.arrowLeft),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

class ComplaintCard extends StatelessWidget {
  final Map<String, dynamic> complaint;

  const ComplaintCard({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

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
            ListTile(
              title: Text(
                complaint['title'],
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Times New Roman',
                    color: Color.fromARGB(255, 21, 98, 113)),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(
                    color: Color.fromARGB(126, 14, 63, 73),
                    thickness: 2,
                  ),
                  Text(
                    complaint['complaint'],
                    style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'Time New Roman',
                        color: Color.fromARGB(255, 14, 63, 73)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Display images if available.
            if (complaint['images'] != null &&
                (complaint['images'] as List).isNotEmpty)
              SizedBox(
                height: 225,
                child: (complaint['images'] as List).length >= 6
                    ? Scrollbar(
                        trackVisibility: true,
                        thumbVisibility: true,
                        controller: scrollController,
                        child: ListView.builder(
                          controller: scrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: (complaint['images'] as List).length,
                          itemBuilder: (context, imgIndex) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  right: 8.0,
                                  left: 8.0,
                                  top: 8.0,
                                  bottom: 15.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: const Color.fromARGB(60, 0, 0, 0),
                                    width: 3.0,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.network(
                                    (complaint['images'] as List)[imgIndex],
                                    width: 225,
                                    height: 225,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: (complaint['images'] as List).length,
                        itemBuilder: (context, imgIndex) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                  color: const Color.fromARGB(60, 0, 0, 0),
                                  width: 3.0,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  complaint['images'][imgIndex] as String,
                                  width: 225,
                                  height: 225,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Text(
                      complaint['date'],
                      style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Time New Roman',
                          color: Color.fromARGB(255, 14, 63, 73)),
                    ),
                  ),
                  Text(
                    complaint['seen'].toLowerCase() == "true"
                        ? 'Seen'
                        : 'Unseen',
                    style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Time New Roman',
                        color: Color.fromARGB(255, 14, 63, 73)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
