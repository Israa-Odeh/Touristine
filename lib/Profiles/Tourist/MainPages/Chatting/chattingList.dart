import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:provider/provider.dart';
import 'package:touristine/Notifications/SnackBar.dart';
import 'package:touristine/Profiles/Tourist/MainPages/Chatting/chatPage.dart';
import 'package:touristine/Profiles/Tourist/MainPages/Chatting/chattingFunctions.dart';
import 'package:touristine/UserData/userProvider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChattingList extends StatefulWidget {
  final String token;

  const ChattingList({super.key, required this.token});

  @override
  _ChattingListState createState() => _ChattingListState();
}

class _ChattingListState extends State<ChattingList> {
  bool isLoading = true;
  List<Map<String, dynamic>> admins = [
    {
      'email': 'IsraaOdeh@gmail.com',
      'firstName': 'Israa',
      'lastName': 'Odeh',
      'image':
          'https://zamzam.com/blog/wp-content/uploads/2021/08/shutterstock_1745937893.jpg'
    },
    {
      'email': 'JenanAbuAlrub@gmailcom.com',
      'firstName': 'Jenan',
      'lastName': 'AbuAlrub',
      'image':
          'https://media.cntraveler.com/photos/639c6b27fe765cefd6b219b7/16:9/w_1920%2Cc_limit/Switzerland_GettyImages-1293043653.jpg'
    },
  ];

  Future<void> getAdminsData() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('https://touristine.onrender.com/get-admins-Data');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
      );
      if (mounted) {
        if (response.statusCode == 200) {
        } else if (response.statusCode == 500) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
        } else {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, 'Error fetching admins list',
              bottomMargin: 0);
        }
      }
    } catch (error) {
      if (mounted) {
        print('Error fetching plans: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> filteredAdmins = [];
  late FocusNode focusNode;
  Color iconColor = Colors.grey;

  @override
  void initState() {
    super.initState();

    // Retrieve list of admins.
    filteredAdmins = List.from(admins);
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
          // Content
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
                  itemCount: filteredAdmins.length,
                  itemBuilder: (context, index) {
                    final admin = filteredAdmins[index];
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
                                FontAwesomeIcons.facebookMessenger,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                              onPressed: () {
                                // Extract the user email from the token.
                                Map<String, dynamic> decodedToken =
                                    Jwt.parseJwt(widget.token);
                                String userEmail = decodedToken['email'];

                                // Retrieve the UserProvider from the context.
                                final UserProvider userProvider =
                                    context.read<UserProvider>();

                                final User user = User(
                                    email: userEmail,
                                    firstName: userProvider.firstName,
                                    lastName: userProvider.lastName,
                                    imagePath: userProvider.imageURL ?? "",
                                    chats: {});
                                addChatToUser(user, admin['email']);
                                // Navigate to the ChatPage passing the admin's name.
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                      adminName:
                                          '${admin['firstName']} ${admin['lastName']}',
                                      adminEmail: admin['email'],
                                      adminImage: admin['image'],
                                      token: widget.token,
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
