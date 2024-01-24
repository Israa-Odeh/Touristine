import 'package:touristine/WebApplication/Notifications/snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class AdminsListPage extends StatefulWidget {
  final String token;

  const AdminsListPage({super.key, required this.token});

  @override
  _AdminsListPageState createState() => _AdminsListPageState();
}

class _AdminsListPageState extends State<AdminsListPage> {
  List<Map<String, dynamic>> admins = [];
  bool isLoading = true;

  Future<void> getAdminsData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('https://touristineapp.onrender.com/get-admins-Data');

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
          final Map<String, dynamic> responseData = json.decode(response.body);
          List<Map<String, dynamic>> fetchedAdmins =
              List<Map<String, dynamic>>.from(responseData['admins']);
          setState(() {
            admins = fetchedAdmins;
          });
          print(admins);
        } else if (response.statusCode == 500) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
        } else {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, 'Error fetching available admins',
              bottomMargin: 0);
        }
      }
    } catch (error) {
      if (mounted) {
        print('Error fetching admins: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getAdminsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/Images/Profiles/Admin/mainBackground.jpg'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E889E)),
              ),
            ),
          if (admins.isEmpty && !isLoading)
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: -10,
                    child: Image.asset(
                      'assets/Images/Profiles/Tourist/emptyListTransparent.gif',
                      fit: BoxFit.fill,
                    ),
                  ),
                  const Positioned(
                    top: 420,
                    child: Text(
                      'No admins found',
                      style: TextStyle(
                        fontSize: 40,
                        fontFamily: 'Gabriola',
                        color: Color.fromARGB(255, 23, 99, 114),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (admins.isNotEmpty && !isLoading)
            Padding(
              padding: const EdgeInsets.only(
                  top: 20.0, bottom: 10, right: 10, left: 10),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Number of cards in each row.
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    mainAxisExtent: 150),
                itemCount: admins.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> adminData = admins[index];
                  Admin admin = Admin(
                    firstName: adminData['firstName'],
                    lastName: adminData['lastName'],
                    email: adminData['email'],
                    image: adminData['image'],
                    city: adminData['city'],
                  );
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: const Color.fromARGB(244, 254, 254, 254),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 50,
                                backgroundImage: (admin.image != null &&
                                        admin.image != "")
                                    ? NetworkImage(admin.image!)
                                    : const AssetImage(
                                            "assets/Images/Profiles/Tourist/DefaultProfileImage.png")
                                        as ImageProvider<Object>?,
                              ),
                              const SizedBox(width: 16),
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${admin.firstName} ${admin.lastName}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      admin.city,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color:
                                            Color.fromARGB(255, 141, 141, 141),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const FaIcon(FontAwesomeIcons.solidTrashCan),
                            onPressed: () {
                              setState(() {
                                deleteAdmin(admin.email);
                              });
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
    );
  }

  Future<void> deleteAdmin(String adminEmail) async {
    bool? confirmDeletion = await showConfirmationDialog(context);

    if (confirmDeletion == true) {
      if (!mounted) return;
      final url = Uri.parse(
          'https://touristineapp.onrender.com/delete-admin/$adminEmail');

      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer ${widget.token}'
          },
        );

        if (!mounted) return;

        if (response.statusCode == 200) {
          setState(() {
            admins.removeWhere((admin) => admin['email'] == adminEmail);
          });
          showCustomSnackBar(context, 'The admin has been deleted',
              bottomMargin: 0);
        } else if (response.statusCode == 500) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
        } else {
          showCustomSnackBar(context, 'Error deleting the admin',
              bottomMargin: 0);
        }
      } catch (error) {
        print('Error deleting the admin: $error');
      }
    }
  }

  Future<bool?> showConfirmationDialog(
    BuildContext context, {
    String dialogMessage = 'Are you sure you want to delete this admin?',
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion',
              style: TextStyle(
                  fontFamily: 'Zilla Slab Light',
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
          content: Text(
            dialogMessage,
            style: const TextStyle(fontFamily: 'Andalus', fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'Zilla',
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                "Delete",
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'Zilla',
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 200, 50, 27),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class Admin {
  final String firstName;
  final String lastName;
  final String email;
  final String? image;
  final String city;

  Admin({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.image,
    required this.city,
  });
}
