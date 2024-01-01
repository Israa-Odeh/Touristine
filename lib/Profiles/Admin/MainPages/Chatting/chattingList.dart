import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:touristine/Profiles/Admin/MainPages/Chatting/chatPage.dart';

class ChattingList extends StatefulWidget {
  final String token;

  const ChattingList({super.key, required this.token});

  @override
  _ChattingListState createState() => _ChattingListState();
}

class _ChattingListState extends State<ChattingList> {
  List<Map<String, dynamic>> tourists = [
    {
      'email': 'NasserOdeh@hotmail.com',
      'firstName': 'Nasser',
      'lastName': 'Odeh',
      'image':
          'https://zamzam.com/blog/wp-content/uploads/2021/08/shutterstock_1745937893.jpg'
    },
    {
      'email': 'AmalOdeh@stu.najah.edu',
      'firstName': 'Amal',
      'lastName': 'Odeh',
      'image':
          'https://media.cntraveler.com/photos/639c6b27fe765cefd6b219b7/16:9/w_1920%2Cc_limit/Switzerland_GettyImages-1293043653.jpg'
    },
    {
      'email': 'AmanyOdeh@stu.najah.edu',
      'firstName': 'Amany',
      'lastName': 'Odeh',
      'image':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/42/OLD_JAFFA_PORT.jpg/1200px-OLD_JAFFA_PORT.jpg'
    },
    // Add more admins as needed
  ];

  List<Map<String, dynamic>> filteredTourists = [];
  late FocusNode focusNode;
  Color iconColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    // Retrieve list of tourists.
    filteredTourists = List.from(tourists);
    focusNode = FocusNode();
    focusNode.addListener(() {
      setState(() {
        iconColor = focusNode.hasFocus ? const Color(0xFF1E889E) : Colors.grey;
      });
    });
  }

  void filterAdmins(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredTourists = List.from(tourists);
      } else {
        filteredTourists = tourists.where((tourist) {
          final fullName = '${tourist['firstName']} ${tourist['lastName']}';
          final queryLowerCase = query.toLowerCase();
          return fullName.toLowerCase().contains(queryLowerCase) ||
              tourist['firstName'].toLowerCase().contains(queryLowerCase) ||
              tourist['lastName'].toLowerCase().contains(queryLowerCase) ||
              fullName.split(' ').every((namePart) =>
                  namePart.toLowerCase().startsWith(queryLowerCase));
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/Images/Profiles/Tourist/homeBackground.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  focusNode: focusNode,
                  onChanged: filterAdmins,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: Icon(
                      FontAwesomeIcons.magnifyingGlass,
                      color: iconColor,
                    ),
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1E889E)),
                    ),
                  ),
                  style: const TextStyle(
                    color: Color.fromARGB(255, 20, 92, 107),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredTourists.length,
                  itemBuilder: (context, index) {
                    final tourist = filteredTourists[index];
                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: const Color.fromARGB(240, 255, 255, 255),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage:
                                      NetworkImage(tourist['image']),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${tourist['firstName']} ${tourist['lastName']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      tourist['email'],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const FaIcon(
                                FontAwesomeIcons.facebookMessenger,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                      touristName:
                                          '${tourist['firstName']} ${tourist['lastName']}',
                                      touristImage: tourist['image'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}