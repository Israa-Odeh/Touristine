import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:touristine/Profiles/Tourist/MainPages/Chatting/chatPage.dart';

class ChattingPage extends StatefulWidget {
  final String token;

  const ChattingPage({Key? key, required this.token}) : super(key: key);

  @override
  _ChattingPageState createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {
  List<Map<String, dynamic>> admins = [
    {
      'email': 'NasserOdeh@gmail.com',
      'firstName': 'Nasser',
      'lastName': 'Odeh',
      'image':
          'https://zamzam.com/blog/wp-content/uploads/2021/08/shutterstock_1745937893.jpg'
    },
    {
      'email': 'AmalOdeh@gmail.com',
      'firstName': 'Jenan',
      'lastName': 'AbuAlrub',
      'image':
          'https://media.cntraveler.com/photos/639c6b27fe765cefd6b219b7/16:9/w_1920%2Cc_limit/Switzerland_GettyImages-1293043653.jpg'
    },
    {
      'email': 'AmanyOdeh@gmail.com',
      'firstName': 'Amany',
      'lastName': 'Odeh',
      'image':
          'https://media.cntraveler.com/photos/639c6b27fe765cefd6b219b7/16:9/w_1920%2Cc_limit/Switzerland_GettyImages-1293043653.jpg'
    },
    // Add more admins as needed
  ];

  List<Map<String, dynamic>> filteredAdmins = [];
  late FocusNode _focusNode;
  Color iconColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    filteredAdmins = List.from(admins);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        iconColor = _focusNode.hasFocus ? const Color(0xFF1E889E) : Colors.grey;
      });
    });
  }

  void _filterAdmins(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredAdmins = List.from(admins);
      } else {
        filteredAdmins = admins.where((admin) {
          final fullName = '${admin['firstName']} ${admin['lastName']}';
          final queryLowerCase = query.toLowerCase();
          return fullName.toLowerCase().contains(queryLowerCase) ||
              admin['firstName'].toLowerCase().contains(queryLowerCase) ||
              admin['lastName'].toLowerCase().contains(queryLowerCase) ||
              fullName.split(' ').every((namePart) =>
                  namePart.toLowerCase().startsWith(queryLowerCase));
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/Images/Profiles/Tourist/homeBackground.jpg', // Replace with your background image URL
              fit: BoxFit.cover,
            ),
          ),
          // Content
          Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  focusNode: _focusNode,
                  onChanged: _filterAdmins,
                  decoration: InputDecoration(
                    hintText: 'Search an Admin',
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
                  itemCount: filteredAdmins.length,
                  itemBuilder: (context, index) {
                    final admin = filteredAdmins[index];
                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: const Color.fromARGB(
                          240, 255, 255, 255), // Set the card color to white
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius:
                                      50, // Set the radius to 50 for a total diameter of 100
                                  backgroundImage: NetworkImage(admin['image']),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${admin['firstName']} ${admin['lastName']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      admin['email'],
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
                                FontAwesomeIcons
                                    .facebookMessenger, // Replace with your desired chat icon
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                              onPressed: () {
                                // Add your logic for the chat button here
                                // Navigate to the ChatPage passing the admin's name
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                      adminName:
                                          '${admin['firstName']} ${admin['lastName']}',
                                      adminImage: admin['image'],
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
