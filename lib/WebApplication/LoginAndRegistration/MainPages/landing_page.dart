import 'package:touristine/WebApplication/LoginAndRegistration/Signup/signup_page.dart';
import 'package:touristine/WebApplication/LoginAndRegistration/Login/login_page.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return AppBar(
                title: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/Images/LandingPage/Logo.png",
                        width: 80,
                        height: 60,
                      ),
                      Text(
                        'Touristine',
                        style: TextStyle(
                          fontFamily: 'Edwardian',
                          fontSize: constraints.maxWidth < 600 ? 30 : 55,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 2, 63, 74),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          backgroundColor:
                              const Color.fromARGB(255, 184, 208, 213),
                          textStyle: TextStyle(
                            fontSize: constraints.maxWidth < 600 ? 15 : 25,
                            fontFamily: 'Zilla',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        child: const Text('Login',
                            style: TextStyle(color: Color(0xFF455a64))),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SignupPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          backgroundColor:
                              const Color.fromARGB(252, 230, 230, 230),
                          textStyle: TextStyle(
                            color: const Color(0xFF455a64),
                            fontSize: constraints.maxWidth < 600 ? 15 : 25,
                            fontFamily: 'Zilla',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        child: const Text('Signup',
                            style: TextStyle(color: Color(0xFF1e889e))),
                      ),
                    ],
                  ),
                ),
                centerTitle: false,
                backgroundColor: const Color(0xFF1E889E),
              );
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  "Experience every moment of Palestine like it's your first!",
                  style: TextStyle(
                    fontSize: 30,
                    fontFamily: 'Gabriola',
                    color: Color(0xFF455a64),
                  ),
                ),
              ),
              Image.asset(
                'assets/Images/LandingPage/Landing.png',
                height: 400,
                width: 400,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
